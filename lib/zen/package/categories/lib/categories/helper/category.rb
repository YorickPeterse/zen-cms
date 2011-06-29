#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper for the Categories package. Note that this helper requires the
    # helper Ramaze::Helper::Message to be loaded.
    #
    # @author Yorick Peterse
    # @since   0.2.7.1
    #
    module Category
      ##
      # Checks if the specified category group ID results in a valid instance of
      # Categories::Model::CategoryGroup. If this is the case the object is
      # returned, otherwise the user is redirected back to the overview of all
      # category groups and is informed about the group being invalid.
      #
      # @author Yorick Peterse
      # @since  0.2.7.1
      # @param  [Fixnum] category_group_id The ID of the category group to
      # validate.
      # @return [Categories::Model::CategoryGroup]
      #
      def validate_category_group(category_group_id)
        group = ::Categories::Model::CategoryGroup[category_group_id]

        if group.nil?
          message(:error, lang('category_groups.errors.invalid_group'))
          redirect(::Categories::Controller::CategoryGroups.r(:index))
        else
          return group
        end
      end

      ##
      # Similar to validate_category_group this method checks if a category is
      # valid or not. If it's valid the object is returned, otherwise an error
      # is displayed and the user is redirected back to the overview of
      # categories.
      #
      # @author Yorick Peterse
      # @since  0.2.7.1
      # @param  [Fixnum] category_id The ID of the category.
      # @param  [Fixnum] category_group_id The ID of the category group, used
      # when redirecting the user.
      # @return [Categories::Model::Category]
      #
      def validate_category(category_id, category_group_id)
        category = ::Categories::Model::Category[category_id]

        if category.nil?
          message(:error, lang('categories.errors.invalid_category'))
          redirect(
            ::Categories::Controller::Categories.r(:index, category_group_id)
          )
        else
          return category
        end
      end
    end # Category
  end # Helper
end # Ramaze
