module CustomFields
  module Controllers
    ##
    # Controller for managing custom fields. Custom fields are one of
    # the most important elements in Zen. Custom fields can be used to
    # create radio buttons, textareas, the whole shebang. Before
    # being able to use a custom field you'll need to add it to a group
    # and bind that group to a section.
    #
    # @author  Yorick Peterse
    # @since   0.1
    #
    class CustomFields < Zen::Controllers::AdminController
      include ::CustomFields::Models

      map '/admin/custom_fields'
      trait :extension_identifier => 'com.zen.custom_fields'
      
      before_all do
        csrf_protection(:save, :delete) do
          respond(@zen_general_lang.errors[:csrf], 403)
        end
      end
      
      ##
      # Constructor method, called upon initialization. It's used to set the
      # URL to which forms send their data and load the language pack.
      #
      # This method loads the following language files:
      #
      # * custom_fields
      # * custom_field_groups
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super
        
        @form_save_url     = CustomFields.r(:save)
        @form_delete_url   = CustomFields.r(:delete)
        @fields_lang       = Zen::Language.load('custom_fields')
        @field_groups_lang = Zen::Language.load('custom_field_groups')
        
        # Set the page title
        if !action.method.nil?
          method = action.method.to_sym
        
          if @fields_lang.titles.key? method
            @page_title = @fields_lang.titles[method]
          end
        end
      end
      
      ##
      # Show an overview of all existing custom fields. Using this overview a user
      # can manage an existing field, delete it or create a new one.
      #
      # This method requires the following permissions:
      #
      # * read
      # 
      # @author Yorick Peterse
      # @param  [Integer] custom_field_group_id The ID of the custom field group to which all fields belong.
      # @since  0.1
      #
      def index custom_field_group_id
        if !user_authorized?([:read])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs(
          anchor_to(@field_groups_lang.titles[:index], CustomFieldGroups.r(:index)),
          @fields_lang.titles[:index]
        )
        
        @custom_field_group_id  = custom_field_group_id.to_i
        @custom_fields          = CustomFieldGroup[@custom_field_group_id].custom_fields
      end
      
      ##
      # Show a form that lets the user edit an existing custom field group.
      #
      # This method requires the following permissions:
      #
      # * read
      # * update
      #
      # @author Yorick Peterse
      # @param  [Integer] custom_field_group_id The ID of the custom field group to which all fields belong.
      # @param  [Integer] id The ID of the custom field to retrieve so that we can edit it.
      # @since  0.1
      #
      def edit custom_field_group_id, id
        if !user_authorized?([:read, :update])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs(
          anchor_to(@field_groups_lang.titles[:index], CustomFieldGroups.r(:index)),
          anchor_to(@fields_lang.titles[:index], CustomFields.r(:index, custom_field_group_id)),
          @fields_lang.titles[:edit]
        )
          
        @custom_field_group_id = custom_field_group_id

        if flash[:form_data]
          @custom_field = flash[:form_data]
        else
          @custom_field = CustomField[id.to_i]
        end
      end
      
      ##
      # Show a form that lets the user create a new custom field group.
      #
      # This method requires the following permissions:
      #
      # * create
      # * read
      #
      # @author Yorick Peterse
      # @param  [Integer] custom_field_group_id The ID of the custom field group to which all fields belong.
      # @since  0.1
      #
      def new custom_field_group_id
        if !user_authorized?([:read, :create])
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        set_breadcrumbs(
          anchor_to(@field_groups_lang.titles[:index], CustomFieldGroups.r(:index)),
          anchor_to(@fields_lang.titles[:index], CustomFields.r(:index, custom_field_group_id)),
          @fields_lang.titles[:index]
        )
        
        @custom_field_group_id = custom_field_group_id
        @custom_field          = CustomField.new
      end
      
      ##
      # Method used for processing the form data and redirecting the user back to
      # the proper URL. Based on the value of a hidden field named 'id' we'll determine
      # if the data will be used to create a new custom field or to update an existing one.
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
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end
        
        post                  = request.params.dup
        custom_field_group_id = post['custom_field_group_id']
        
        post.delete('slug') if post['slug'].empty?

        # Get or create a custom field group based on the ID from the hidden field.
        if post['id'] and !post['id'].empty?
          @custom_field = CustomField[post['id'].to_i]
          save_action   = :save
        else
          @custom_field = CustomField.new
          save_action   = :new
        end
        
        flash_success = @fields_lang.success[save_action]
        flash_error   = @fields_lang.errors[save_action]

        begin
          @custom_field.update(post)
          notification(:success, @fields_lang.titles[:index], flash_success)
        rescue
          notification(:error, @fields_lang.titles[:index], flash_error)

          flash[:form_data]   = @custom_field
          flash[:form_errors] = @custom_field.errors
        end
        
        if @custom_field.id
          redirect(CustomFields.r(:edit, custom_field_group_id, @custom_field.id))
        else
          redirect(CustomFields.r(:new, custom_field_group_id))
        end
      end
      
      ##
      # Delete an existing custom field.
      #
      # In order to delete a custom field group you'll need to send a POST request that contains
      # a field named 'custom_field_ids[]'. This field should contain the primary values of
      # each field that has to be deleted.
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
          respond(@zen_general_lang.errors[:not_authorized], 403)
        end

        post = request.params.dup
        
        if !request.params['custom_field_ids'] or request.params['custom_field_ids'].empty?
          notification(:error, @fields_lang.titles[:index], @fields_lang.errors[:no_delete])
          redirect(CustomFields.r(:index, post['custom_field_group_id']))
        end
        
        request.params['custom_field_ids'].each do |id|
          begin
            CustomField[id.to_i].destroy
            notification(:success, @fields_lang.titles[:index], @fields_lang.success[:delete])
          rescue
            notification(:error, @fields_lang.titles[:index], @fields_lang.errors[:delete] % id)
          end
        end
        
        redirect_referrer
      end
    end
  end
end
