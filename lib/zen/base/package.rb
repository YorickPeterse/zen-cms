require 'ramaze/gestalt'

module Zen
  ##
  # Module used for registering extensions and themes, setting their details and the whole shebang.
  # Packages follow the same directory structure as Rubygems and can actually be installed
  # using either Rubygems or by storing them in a custom directory. As long as you require
  # the correct file you're good to go.
  #
  # Packages are added or "described" using a simple block and the add() method as following:
  #
  # bc. Zen::Package.add do |ext|
  #   # ....
  # end
  #
  # When using this block you're required to set the following attributes:
  #
  # * type: the type of package, can either be "theme" or "extension"
  # * name: the name of the package
  # * author: the name of the person who made the package
  # * version: the current version, either a string or a numeric value
  # * about: a small description of the package
  # * url: the URL to the package's website
  # * identifier: unique identifier for the package. The format is com.AUTHOR.NAME for
  # extensions and com.AUTHOR.themes.NAME for themes.
  # * directory: the root directory of the package, set this using __DIR__('path')
  # 
  # Optionally you can also specify the attribute "menu" (more on that later).
  #
  # h2. Menu Items
  #
  # The package system easily allows modules to add navigation/sub-navigation elements
  # to the backend menu. Each extension can have an attribute named "menu", this attribute
  # is an array of hashes. Each hash must have the following 2 keys (they're symbols):
  #
  # * title: the value used for both the title tag and the text of the anchor element
  # * url: the URI the navigation item will point to. Leading slash isn't required
  #
  # Optionally you can specify child elements using the "children" key. This key
  # will again contain an array of hashes just like regular navigation elements.
  # For example, one could do the following:
  #
  # @ext.menu = [{:title => "Dashboard", :url => "admin/dashboard"}]@
  #
  # Adding a number of child elements isn't very difficult either:
  #
  # bc. ext.menu = [{
  #   :title    => "Dashboard", :url => "admin/dashboard",
  #   :children => [{:title => "Child", :url => "admin/dashboard/child"}]
  # }]
  #
  # Once a certain number of navigation elements have been added you can generate the
  # HTML for a fully fledged navigation menu using the build_menu() method. This method
  # uses Gestalt to build the HTML and also takes care of permissions for each user/module.
  #
  # h2. Migrations
  #
  # If your package uses it's own database tables it's best to use migrations as these make
  # it very easy to install/uninstall the extension. Migrations should be put in the root
  # directory of your extension. For example, if your extension is in "foobar" the migrations
  # should be located in "foobar/migrations", the lib directory in "foobar/lib", etc.
  #
  # Migrations can be executed using the Rake task "extension:migrate" or "db:migrate",
  # the latter will install all extensions while the first one will only install the specified
  # extension. Migration prototypes can be generated by the Rake task
  # "proto:migration[DIRECTORY]" where DIRECTORY is the path to your migrations directory.
  #
  # h2. Themes
  #
  # Themes are essentially packages like the sections or comments module except that they
  # have a few limitations and work a bit different. First of all themes can't add navigation
  # items to the backend and second they should _always_ have the following directories:
  #
  # * theme/lib/theme/templates
  # * theme/lib/theme/public
  #
  # The templates directory is used to store all Liquid templates and template groups, the public
  # directory is used for CSS files, images and so on. Themes can have migrations just
  # like extensions which makes it relatively easy to share a theme with somebody else.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  module Package
    class << self
      attr_reader :extensions
      attr_reader :themes
      attr_accessor :classes
    end
    
    ##
    # Adds a new package along with all it's details such as the name,
    # author, version and so on. Extensions can be added using a simple
    # block as following:
    #
    #  Zen::Package.add do |ext|
    #    ext.name   = "Name"
    #    ext.author = "Author"
    #  end
    #
    # When adding a new extension the following setters are required:
    #
    # * type
    # * name
    # * author
    # * version
    # * about
    # * url
    # * identifier
    # * directory
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [Block] block Block containing information about the extension.
    #
    def self.add(&block)
      package  = Struct.new(:type, :name, :author, :version, :about, :url,
        :identifier, :directory, :menu).new
      required = [:type, :name, :author, :version, :about, :url, :identifier, :directory]
      
      yield package
      
      required.each do |m|
        if !package.respond_to?(m) or package.send(m).nil?
          raise "A loaded package has no value set for the setter \"#{m}\""
        end
      end

      # Update the root but prevent duplicates
      if !Ramaze.options.roots.include?(package.directory)
        Ramaze.options.roots.push(package.directory)
      end
      
      # Themes and extensions each have a different accessor
      if package.type.to_s == 'theme'
        # Remove the navigation menu
        package.menu = nil if !package.menu.nil?
        
        @themes                          = {} if @themes.nil?
        @themes[package.identifier.to_s] = package
      else
        @extensions                          = {} if @extensions.nil?
        @extensions[package.identifier.to_s] = package
      end
    end
    
    ##
    # Shortcut method that can be used to retrieve an extension or theme based on the
    # given extension identifier.
    #
    # @author Yorick Peterse
    # @param  [String] ident The package's identifier
    # @return [Object]
    #
    def self.[](ident)
      if ident.include?('.themes.')
        @themes[ident]
      else
        @extensions[ident]
      end
    end
    
    ##
    # Builds a navigation menu for all installed extensions.
    # Extensions can have an infinite amount of sub-navigation
    # items. This method will generate an unordered list of items
    # of which each list item can contain N sub items.
    #
    # @author Yorick Peterse
    # @param  [String] css_class A string of CSS classes to apply to the
    # main UL element.
    # @since  0.1
    #
    def self.build_menu css_class = ''
      @g         = Ramaze::Gestalt.new
      menu_items = []
      
      @extensions.each do |ident, ext|
        if !ext.menu.nil?
          ext.menu.each do |m|
            menu_items.push(m)
          end
        end
      end
      
      # Sort the menu alphabetical
      menu_items = menu_items.sort_by do |item|
        item[:title]
      end
      
      @g.ul :class => css_class do
        if !menu_items.empty?
          menu_items.each do |m|
            self.nav_list(m)
          end
        end
      end
      
      return @g.to_s
    end
    
    private
    
    ##
    # Method that's used to generate the list items for each
    # navigation menu along with all sub elements.
    #
    # @author Yorick Peterse
    # @param  [Hash] menu Hash containing the navigation items (url, title, etc)
    # @since  0.1
    #
    def self.nav_list menu
      @g.li do
        if menu[:url][0] != '/'
          menu[:url] = '/' + menu[:url]
        end
        
        @g.a :href => menu[:url], :title => menu[:title] do
          menu[:title]
        end
        
        if menu.key?(:children)
          @g.ul do
            menu[:children].each do |c|
              self.nav_list(c)
            end
          end
        end
      end
    end
    
  end
end