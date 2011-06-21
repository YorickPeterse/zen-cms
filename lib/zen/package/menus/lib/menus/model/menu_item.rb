#:nodoc:
module Menus
  #:nodoc:
  module Model
    ##
    # Model used for managing individual menu items in a group.
    # This model uses the following plugins:
    #
    # * tree
    #
    # @author Yorick Peterse
    # @since  0.2a
    #
    class MenuItem < Sequel::Model
      plugin :tree, :order => :sort_order

      many_to_one :menu  , :class => 'Menus::Model::Menu'
      many_to_one :parent, :class => self

      ##
      # Specifies all validation rules that will be used when creating or updating a 
      # menu item.
      #
      # @author Yorick Peterse
      # @since  0.2a
      #
      def validate
        validates_presence :name
        validates_integer  [:sort_order, :parent_id]
        
        # Prevent people from entering random crap for class and ID names
        validates_format(/^[a-zA-Z\-_0-9]*/, [:css_class, :css_id])
      end
    end # MenuItem
  end # Model
end # Menus
