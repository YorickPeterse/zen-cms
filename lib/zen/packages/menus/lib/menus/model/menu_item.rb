module Menus
  module Models
    ##
    # Model used for managing individual menu items in a group.
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    class MenuItem < Sequel::Model
      plugin :tree, :order => :order

      ##
      # Specifies all validation rules that will be used when creating or updating a 
      # menu item.
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def validate
        validates_presence [:name, :url]
        validates_integer [:order, :parent_id]
        
        # Prevent people from entering random crap for class and ID names
        validates_format(/^[a-zA-Z\-_0-9]*/, [:css_class, :css_id])
      end
    end
  end
end
