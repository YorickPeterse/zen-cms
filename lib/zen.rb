##
# Main module for Zen, all other modules and classes will be placed inside this module.
# This module loads all required classes and is used for starting the application.
#
# @author Yorick Peterse
# @since  0.1
#
module Zen
  require 'sequel'
  require 'ramaze'
  require 'bcrypt'
  require 'liquid'
  require 'json'
  require 'redcloth'
  require 'rdiscount'
  require 'defensio'
  require __DIR__('zen/base/version')
  
  include Innate::Optioned
  
  # Update several paths so we can load helpers/layouts from the Zen gem
  Innate::HelpersHelper.options.paths << __DIR__('zen')
  Ramaze.options.roots << __DIR__('zen')
  
  options.dsl do
    # General configuration options
    o 'The character encoding to use when dealing with data',   :encoding,       'utf8'
    o 'The system language',                                    :language,       'en'
    o 'The date format to use for log files and such.',         :date_format,    '%d-%m-%Y'
    o 'The base directory of Zen.',                             :root,           ''
  end
  
  # Load all classes/modules provided by Zen itself.
  require __DIR__ 'zen/base/logger'
  require __DIR__ 'zen/base/database'
  require __DIR__ 'zen/base/extensions'
  require __DIR__ 'zen/base/language'
  
  # Load all the base controllers
  require __DIR__ 'zen/controller/base_controller'
  require __DIR__ 'zen/controller/frontend_controller'
  require __DIR__ 'zen/controller/admin_controller'
  require __DIR__ 'zen/controller/main_controller'
  
  # Load all default Liquid tags
  require __DIR__ 'zen/liquid/general'
  require __DIR__ 'zen/liquid/controller_behavior'
  require __DIR__ 'zen/liquid/redirect'
  require __DIR__ 'zen/liquid/strip'
  
  class << self
    attr_accessor :logger
  end
  
  # Update the language paths
  Zen::Language.language_paths << __DIR__('zen')
  
  # Register our Liquid tags
  ::Liquid::Template.register_tag('strip'   , Liquid::Strip)
  ::Liquid::Template.register_tag('redirect', Liquid::Redirect)

  ##
  # Intitializes Zen by connecting the database and setting up various other things.
  #
  # @author Yorick Peterse
  #
  def self.init
    # Initialize the database
    Zen::Database.init
    
    require __DIR__ 'zen/model/settings'
    require __DIR__ 'zen/model/methods'
    
    # Initialize the logger
    @logger = Zen::Logger.new("#{Zen.options.root}/logs/common")
  end
end