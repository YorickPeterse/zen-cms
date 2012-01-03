module Users
  #:nodoc:
  module Model
    ##
    # Model that represents a single user group.
    #
    # @since  0.1
    #
    class UserGroup < Sequel::Model
      include Zen::Model::Helper

      many_to_many :users      , :class => 'Users::Model::User'
      one_to_many  :permissions, :class => 'Users::Model::Permission'

      plugin :sluggable, :source => :name, :freeze => false
      plugin :association_dependencies, :permissions => :delete,
        :users => :nullify

      ##
      # Searches for a set of users that match the given query.
      #
      # @since  16-10-2011
      # @param  [String] query The search query.
      # @return [Mixed]
      #
      def self.search(query)
        return filter(search_column(:name, query))
      end

      ##
      # Validation rules for each user group used when
      # creating or updating a group.
      #
      # @since  0.1
      #
      def validate
        validates_presence([:name, :super_group])
        validates_max_length(255, :name)
        validates_unique(:slug)

        validates_type(TrueClass, :super_group)
      end

      ##
      # Hook that is executed before creating or saving an object.
      #
      # @since 03-01-2012
      #
      def before_save
        sanitize_fields([:name, :slug, :description])

        super
      end
    end # UserGroup
  end # Model
end # Users
