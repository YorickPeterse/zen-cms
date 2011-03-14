#:nodoc:
module Categories 
  #:nodoc:
  module Controllers
    ##
    # Categories can be seen as "tags" for your section entries. They describe the
    # type of entry just like tags except that categories generally cover larger elements.
    # When adding a new entry categories aren't required so you're free to ignore 
    # them if you don't need them.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Categories < Zen::Controllers::AdminController
      include ::Categories::Models
      
      map '/admin/categories'
      trait :extension_identifier => 'com.zen.categories'
      
      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end
      
      ##
      # The constructor is used to set various options such as the form URLs and load
      # the language pack for the categories module.
      #
      # The following language files are loaded:
      #
      # * categories
      # * category_groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url   = Categories.r(:save)
        @form_delete_url = Categories.r(:delete)

        Zen::Language.load('categories')
        Zen::Language.load('category_groups')
        
        # Set the page title
        if !action.method.nil?
          method      = action.method.to_s
          @page_title = lang("categories.titles.#{method}") rescue nil
        end
      end
      
      ##
      # Show an overview of all existing categories and allow the user
      # to create and manage these categories.
      #
      # This method requires the following permissions:
      #
      # * read
      #
      # @author Yorick Peterse
      # @param  [Integer] category_group_id The ID of the category group that's currently
      # being managed by the user.
      # @since  0.1
      #
      def index category_group_id
        if !user_authorized?([:read])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('category_groups.titles.index'), CategoryGroups.r(:index)),
          lang('categories.titles.index')
        )
        
        @category_group_id = category_group_id.to_i
        @categories        = CategoryGroup[@category_group_id].categories
      end
      
      ##
      # Edit an existing category based on the ID specified in the URL.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Integer] category_group_id The category group ID.
      # @param  [Integer] id The ID of the category to edit.
      # @since  0.1
      #
      def edit category_group_id, id
        if !user_authorized?([:read, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('category_groups.titles.index'), CategoryGroups.r(:index)),
          anchor_to(lang('categories.titles.index'), Categories.r(:index, category_group_id)),
          lang('categories.titles.edit')
        )
          
        @category_group_id = category_group_id.to_i

        if flash[:form_data]
          @category = flash[:form_data]
        else
          @category = Category[id.to_i]
        end
      end
      
      ##
      # Create a new category.
      #
      # This method requires the following permissions:
      #
      # * read
      # * create
      #
      # @author Yorick Peterse
      # @param  [Integer] category_group_id The ID of the category group.
      # @since  0.1
      #
      def new category_group_id
        if !user_authorized?([:read, :create])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        set_breadcrumbs(
          anchor_to(lang('category_groups.titles.index'), CategoryGroups.r(:index)),
          anchor_to(lang('categories.titles.index'), Categories.r(:index, category_group_id)),
          lang('categories.titles.new')
        )
          
        @category_group_id = category_group_id.to_i
        @category          = Category.new
      end

      ##
      # Save the changes made to an existing category or create a new one based
      # on the current POST data.
      #
      # This method requires the following permissions:
      #
      # * create
      # * update
      #
      # @author Yorick Peterse
      # @since  0.1
      #    
      def save
        if !user_authorized?([:create, :update])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        post              = request.params.dup
        category_group_id = post['category_group_id']
        
        post.delete('slug') if post['slug'].empty?

        # Retrieve the category and set the notifications based on if the ID has
        # been specified or not.
        if post['id'] and !post['id'].empty?
          @category   = Category[post['id'].to_i]
          save_action = :save
        else
          @category   = Category.new
          save_action = :new
        end
        
        flash_success = lang("categories.success.#{save_action}")
        flash_error   = lang("categories.errors.#{save_action}")
        
        # Try to update the category
        begin
          @category.update(post)
          notification(:success, lang('categories.titles.index'), flash_success)
        rescue
          notification(:error, lang('categories.titles.index'), flash_error)
 
          flash[:form_errors] = @category.errors
          flash[:form_data]   = @category
        end
        
        if @category.id
          redirect(Categories.r(:edit, category_group_id, @category.id))
        else  
          redirect(Categories.r(:new, category_group_id))
        end
      end
      
      ##
      # Delete all specified category groups and their categories. In
      # order to delete a number of groups an array of fields, named "category_group_ids"
      # is required. This array will contain all the primary values of each group that
      # has to be deleted.
      #
      # This method requires the following permissions:
      #
      # * delete
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        if !user_authorized?([:delete])
          respond(lang('zen_general.errors.not_authorized'), 403)
        end
        
        post              = request.params.dup
        category_group_id = post['category_group_id'].to_i
        
        # Obviously we'll require some IDs
        if !request.params['category_ids'] or request.params['category_ids'].empty?
          notification(
            :error, 
            lang('categories.titles.index'), 
            lang('categorieserrors.no_delete')
          )

          redirect(Categories.r(:index, category_group_id))
        end
        
        # Delete each section
        request.params['category_ids'].each do |id|
          begin
            Category[id.to_i].destroy
            notification(
              :success, 
              lang('categories.titles.index'), 
              lang('categories.success.delete')
            )

          rescue
            notification(
              :error, 
              lang('categories.titles.index'), 
              lang('categories.errors.delete') % id
            )

          end
        end
        
        redirect(Categories.r(:index, category_group_id))
      end
    end
  end
end
