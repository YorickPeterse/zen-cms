require 'ramaze'
require 'yaml'

Ramaze.setup(:verbose => false) do
  gem 'sequel'      , ['~> 3.28.0']
  gem 'bcrypt-ruby' , ['~> 3.0.1'], :lib => 'bcrypt'
  gem 'loofah'      , ['~> 1.2.0']
  gem 'json'        , ['~> 1.6.1']
  gem 'ramaze-asset', ['~> 0.2.3'], :lib => 'ramaze/asset'
end

unless $LOAD_PATH.include?(__DIR__)
  $LOAD_PATH.unshift(__DIR__)
end

##
# Main module for Zen, all other modules and classes will be placed inside this
# module. This module loads all required classes and is used for starting the
# application.
#
# @since  0.1
#
module Zen
  class << self
    # The database connection to use for Sequel.
    attr_accessor :database

    # Instance of Ramaze::Asset::Environment to use for all backend assets.
    attr_accessor :asset

    ##
    # Returns the current root directory.
    #
    # @since  0.3
    #
    def root
      @root
    end

    ##
    # Sets the root directory and adds the path to Ramaze.options.roots.
    #
    # @since  0.3
    #
    def root=(path)
      @root = path

      if !Ramaze.options.roots.include?(@root)
        Ramaze.options.roots.push(@root)
      end
    end

    ##
    # Prepares Zen for the party of it's life.
    #
    # @since  0.3
    #
    def start
      if root.nil?
        raise('You need to specify a valid root directory in Zen.root')
      end

      require 'zen/model/init'
      require 'zen/model/methods'

      # Set up Ramaze::Asset
      setup_assets

      # Load all packages
      require 'zen/package/all'

      # Load the global stylesheet and Javascript file if they're located in
      # ROOT/public/css/admin/global.css and ROOT/public/js/admin/global.js
      load_global_assets

      # Migrate all settings
      begin
        Settings::Setting.migrate
      rescue => e
        Ramaze::Log.warn(
          'Failed to migrate the settings, make sure the database ' \
            'table is up to date and that you executed rake db:migrate.'
        )
      end

      Zen.asset.build(:javascript)
      Zen.asset.build(:css)
    end

    private

    ##
    # Configures Ramaze::Asset and loads all the global assets.
    #
    # @since  0.3
    #
    def setup_assets
      cache_path = File.join(root, 'public', 'minified')

      if !File.directory?(cache_path)
        Dir.mkdir(cache_path)
      end

      Zen.asset = Ramaze::Asset::Environment.new(
        :cache_path => cache_path,
        :minify     => Ramaze.options.mode == :live
      )

      Zen.asset.serve(
        :css,
        [
          'admin/css/zen/reset',
          'admin/css/zen/grid',
          'admin/css/zen/layout',
          'admin/css/zen/general',
          'admin/css/zen/forms',
          'admin/css/zen/tables',
          'admin/css/zen/buttons',
          'admin/css/zen/messages'
        ],
        :name => 'zen_core'
      )

      Zen.asset.serve(
        :javascript,
        [
          'admin/js/vendor/mootools/core',
          'admin/js/vendor/mootools/more',
          'admin/js/zen/lib/language',
          'admin/js/zen/lib/html_table',
          'admin/js/zen/index'
        ],
        :name => 'zen_core'
      )

      # Add all the asset groups.
      require 'zen/asset_groups'
    end

    ##
    # Loads a global CSS and JS file.
    #
    # @since  0.3
    #
    def load_global_assets
      publics    = Ramaze.options.publics
      css_loaded = false
      js_loaded  = false

      publics.each do |p|
        p   = File.join(Zen.root, p)
        css = File.join(p, 'admin/css/global.css')
        js  = File.join(p, 'admin/js/global.js')

        if File.exist?(css) and css_loaded == false
          Zen.asset.serve(:css, ['admin/css/global'])
          css_loaded = true
        end

        if File.exist?(js) and js_loaded == false
          Zen.asset.serve(:javascript, ['admin/js/global'])
          js_loaded = true
        end
      end
    end
  end # class << self
end # Zen

require __DIR__('vendor/sequel_sluggable')
require 'zen/version'

Ramaze::Cache.options.names.push(:settings)
Ramaze::Cache.options.settings = Ramaze::Cache::LRU

# Load all classes/modules provided by Zen itself.
require 'zen/error'
require 'zen/language'
require 'zen/validation'
require 'zen/event'
require 'zen/model/helper'

Ramaze::HelpersHelper.options.paths.push(__DIR__('zen'))
Ramaze.options.roots.push(__DIR__('zen'))
Zen::Language.options.paths.push(__DIR__('zen'))

Zen::Language.load('zen_general')

include Zen::Language::SingletonMethods

require 'zen/markup'
require 'zen/package'
require 'zen/theme'
require 'zen/plugin/helper'

# Load all the base controllers
require 'zen/controller/base_controller'
require 'zen/controller/frontend_controller'
require 'zen/controller/admin_controller'
require 'zen/controller/main_controller'
require 'zen/controller/preview'
require 'zen/controller/translations'
