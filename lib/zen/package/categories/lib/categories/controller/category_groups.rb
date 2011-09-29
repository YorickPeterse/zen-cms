##
# Package for managing categories and category groups.
#
# This package provides the following controllers:
#
# * {Categories::Controller::CategoryGroups}
# * {Categories::Controller::Categories}
#
# The following models come with this package:
#
# * {Categories::Model::CategoryGroup}
# * {Categories::Model::Category}
#
# It also provides the following plugins:
#
# * {Categories::Plugin::Categories}
#
# @author Yorick Peterse
# @since  0.1
#
module Categories
  #:nodoc:
  module Controller
    ##
    # Category groups are containers for individual categories. A category group
    # can be assigned to multiple sections and it can have multiple categories.
    #
    # ## Available Fields
    #
    # The following fields can be set:
    #
    # * **Name**: the name of the category group. It can be any name in any
    #   format as long as it's not longer than 255 characters.
    # * **Description**: the description of the category group. While not
    #   required it can be used to make it easier to remember that purpose a
    #   category group has.
    #
    # ## Used Permissions
    #
    # * show_category_group
    # * edit_category_group
    # * new_category_group
    # * delete_category_group
    #
    # ## Events
    #
    # All available events receive an instance of
    # {Categories::Model::CategoyGroup}.  However, the ``delete_category_group``
    # event will receive an instance that has already been removed from the
    # database. This means that you can not make changes to the object and call
    # ``#save()``.
    #
    # @example Logging when a new category group is created
    #  Zen::Event.listen(:new_category_group) do |group|
    #    Ramaze::Log.info("New category: \"#{group.name}\"")
    #  end
    #
    # @example Automatically adding a category group to a section
    #  Zen::Event.listen(:new_category_group) do |group|
    #    section = Sections::Model::Section[5]
    #
    #    begin
    #      section.add_category_group(group)
    #    rescue => e
    #      Ramaze::Log.error(e.inspect)
    #    end
    #  end
    #
    # @author Yorick Peterse
    # @since  0.1
    # @map    /admin/category-groups
    # @event  new_category_group
    # @event  edit_category_group
    # @event  delete_category_group
    #
    class CategoryGroups < Zen::Controller::AdminController
      helper :category
      map    '/admin/category-groups'
      title  'category_groups.titles.%s'

      # Protects CategoryGroups#save() and CategoryGroups#delete() against CSRF
      # attacks.
      csrf_protection :save, :delete

      ##
      # Show an overview of all existing category groups and allow the user
      # to create new category groups or manage individual categories.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @permission show_category_group
      # @request    GET /admin/category-groups/
      # @request    GET /admin/category-groups/index/
      #
      def index
        authorize_user!(:show_category_group)

        set_breadcrumbs(lang('category_groups.titles.index'))

        @category_groups = paginate(::Categories::Model::CategoryGroup)
      end

      ##
      # Allows a user to edit an existing category group.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @param      [Fixnum] id The ID of the category group to edit.
      # @permission edit_category_group
      # @request    GET /admin/category-groups/edit/N/ where N is an ID
      #
      def edit(id)
        authorize_user!(:edit_category_group)

        set_breadcrumbs(
          CategoryGroups.a(lang('category_groups.titles.index'), :index),
          lang('category_groups.titles.edit')
        )

        @category_group = flash[:form_data] || validate_category_group(id)

        render_view(:form)
      end

      ##
      # Allows the user to add a new category group.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @permission new_category_group
      # @request    GET /admin/category-group/new/
      #
      def new
        authorize_user!(:new_category_group)

        set_breadcrumbs(
          CategoryGroups.a(lang('category_groups.titles.index'), :index),
          lang('category_groups.titles.new')
        )

        if flash[:form_data]
          @category_group = flash[:form_data]
        else
          @category_group = ::Categories::Model::CategoryGroup.new
        end

        render_view(:form)
      end

      ##
      # Creates a new category or updates the data of an existing category. If a
      # category ID is specified (in the POST key "id") that existing category
      # will be updated, otherwise a new one will be created.
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @request    POST /admin/category-groups/save/
      # @permission edit_category_group
      # @permission new_category_group
      # @event      new_category_group
      # @event      edit_category_group
      #
      def save
        post = request.subset(:id, :name, :description)

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_category_group)

          category_group = validate_category_group(post['id'])
          save_action    = :save
          event          = :new_category_group
        else
          authorize_user!(:new_category_group)

          category_group = ::Categories::Model::CategoryGroup.new
          save_action    = :new
          event          = :edit_category_group
        end

        success = lang("category_groups.success.#{save_action}")
        error   = lang("category_groups.errors.#{save_action}")

        post.delete('id')

        begin
          category_group.update(post)
        rescue => e
          message(:error, error)
          Ramaze::Log.error(e.inspect)

          flash[:form_data]   = category_group
          flash[:form_errors] = category_group.errors

          redirect_referrer
        end

        Zen::Event.call(event, category_group)

        message(:success, success)
        redirect(CategoryGroups.r(:edit, category_group.id))
      end

      ##
      # Deletes a number of category groups. The IDs of these groups should be
      # specified in the POST array "category_group_ids".
      #
      # @author     Yorick Peterse
      # @since      0.1
      # @request    POST /admin/category-groups/delete/
      # @permission delete_category_group
      # @event      delete_category_group
      #
      def delete
        authorize_user!(:delete_category_group)

        post = request.subset(:category_group_ids)

        if post['category_group_ids'].nil? or post['category_group_ids'].empty?
          message(:error, lang('category_groups.errors.no_delete'))
          redirect(CategoryGroups.r(:index))
        end

        post['category_group_ids'].each do |id|
          group = ::Categories::Model::CategoryGroup[id]

          next if group.nil?

          begin
            group.destroy
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('category_groups.errors.delete') % id)

            redirect_referrer
          end

          Zen::Event.call(:delete_category_group, group)
        end

        message(:success, lang('category_groups.success.delete'))
        redirect_referrer
      end
    end # CategoryGroups
  end # Controller
end # Categories
