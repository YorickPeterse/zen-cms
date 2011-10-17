module Zen
  module Model
    ##
    # Zen::Model::Helper is a helper module that contains a few methods for
    # Sequel models. Using this helper can be done by simply including it into
    # your model:
    #
    #     class MyModel < Sequel::Model
    #       include Zen::Model::Helper
    #     end
    #
    # See the individual methods in this module for more information.
    #
    # @author Yorick Peterse
    # @since  16-10-2011
    #
    module Helper
      # Array containing the database adapters that don't support regular
      # expressions.
      NoRegexpSupport = [:sqlite]

      ##
      # Extends the including class with the methods in the {ClassMethods}
      # module.
      #
      # @author Yorick Peterse
      # @since  16-10-2011
      #
      def self.included(into)
        into.extend(ClassMethods)
      end

      # The methods in this module will be added as class methods to the
      # including class.
      module ClassMethods
        ##
        # Given a column name and a value this method will determine whether a
        # regular expression should be used or a simple LIKE statement. If the
        # DBMS supports the use of regular expressions those will be used,
        # otherwise a LIKE in the format of "%VALUE%" is used.
        #
        # The return value of this method is either a ``Hash`` containing the
        # column and the regular expression or an instance of
        # ``Sequel::SQL::BooleanExpression``.
        #
        # @example Using a DBMS that supports the use of a regex
        #  search_column(:name, 'ruby \d+') # => {:name => /ruby \d+/i}
        #
        # @example Using a DBMS that does not support the use of a regex
        #  search_column(:name, 'ruby \d+') # => #<Sequel::SQL::BooleanExpression ....>
        #
        # @author Yorick Peterse
        # @since  16-10-2011
        # @param  [Symbol] column The column to use in the statement.
        # @param  [String] value The value for the statement.
        # @return [Hash|Sequel::SQL::BooleanExpression]
        #
        def search_column(column, value)
          if NoRegexpSupport.include?(Zen.database.adapter_scheme)
            return column.like("%#{value}%")
          else
            return {column => /#{value}/i}
          end
        end
      end # ClassMethods
    end # Helper
  end # Model
end # Zen
