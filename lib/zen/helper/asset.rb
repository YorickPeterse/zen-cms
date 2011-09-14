module Ramaze
  module Helper
    ##
    # Helper that makes it a bit easier to add assets to Zen.asset. All assets
    # added via this module are *only* loaded for the class that called the
    # method.
    #
    # @author Yorick Peterse
    # @since  0.2.9
    #
    module Asset
      ##
      # Extends the including class with the ClassMethods module.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      # @param  [Class] klass The klass that included this module.
      #
      def self.included(klass)
        klass.extend(Ramaze::Helper::Asset::ClassMethods)
      end

      ##
      # Module of which the methods will become available as class methods to
      # the class that included Ramaze::Helper::Asset.
      #
      # @author Yorick Peterse
      # @since  0.2.9
      #
      module ClassMethods
        ##
        # Provides a shortcut method to Zen.asset.serve() and automatically
        # loads all the given assets for the calling class.
        #
        # @author Yorick Peterse
        # @since  0.2.9
        # @see    Ramaze::Asset::Environment#serve()
        #
        def serve(type, files, options = {})
          Zen.asset.serve(type, files, options.merge({:controller => self}))
        end

        ##
        # Loads an asset group. This method can either load a single asset group
        # or an array of groups.
        #
        # @example
        #  load_asset_group(:datepicker)
        #  load_asset_group([:editor, :datepicker])
        #
        # @author Yorick Peterse
        # @since  0.2.9
        # @see    Ramaze::Asset::Environment#load_asset_group()
        # @param  [Array] methods An array of methods to load the assets for.
        #
        def load_asset_group(name, methods = nil)
          if name.respond_to?(:each)
            name.each do |n|
              Zen.asset.load_asset_group(n, self, methods)
            end
          else
            Zen.asset.load_asset_group(name, self, methods)
          end
        end
      end # ClassMethods
    end # Asset
  end # Helper
end # Ramaze
