require File.expand_path('../../../../../helper', __FILE__)

describe('CustomFields::Controller::CustomFieldTypes') do
  behaves_like :capybara

  it('Submit a form without a CSRF token') do
    response = page.driver.post(
      CustomFields::Controller::CustomFieldTypes.r(:save).to_s
    )

    response.body.include?(lang('zen_general.errors.csrf')).should === true
    response.status.should                                         === 403
  end

  it('A number of field types should exist') do
    index_url = CustomFields::Controller::CustomFieldTypes.r(:index).to_s
    message   = lang('custom_field_types.messages.no_field_types')
    rows      = CustomFields::Model::CustomFieldType.count

    visit(index_url)

    current_path.should                          === index_url
    page.has_content?(message).should            === false
    page.has_selector?('table tbody tr').should  === true
    page.all('table tbody tr').count.should      === rows
  end

  it('Create a new custom field type') do
    index_url   = CustomFields::Controller::CustomFieldTypes.r(:index).to_s
    new_url     = CustomFields::Controller::CustomFieldTypes.r(:new).to_s
    edit_url    = CustomFields::Controller::CustomFieldTypes.r(:edit).to_s
    new_button  = lang('custom_field_types.buttons.new')
    save_button = lang('custom_field_types.buttons.save')
    method_id   = CustomFields::Model::CustomFieldMethod[
      :name => 'input_text'
    ].id.to_s

    visit(index_url)
    click_link(new_button)

    current_path.should === new_url

    # Submit the form
    within('#custom_field_type_form') do
      # Fill in various text fields
      fill_in('form_name', :with => 'Spec type')

      fill_in(
        'form_language_string',
        :with => 'custom_fields.special.type_hash.textbox'
      )

      fill_in('form_html_class', :with => 'spec_class')

      # Choose "Yes" for the serialize and allow_markup options
      choose('form_serialize_0')
      choose('form_allow_markup_0')

      select('input_text', :from => 'form_custom_field_method_id')

      click_on(save_button)
    end

    # Validate the results
    current_path.should =~ /#{edit_url}\/\d+/

    page.find_field('form_name').value.should === 'Spec type'

    page.find_field('form_language_string') \
      .value.should === 'custom_fields.special.type_hash.textbox'

    page.find_field('form_html_class').value.should      === 'spec_class'
    page.find_field('form_serialize_0').checked?.should === 'checked'

    page.find_field('form_allow_markup_0').checked?.should      === 'checked'
    page.find_field('form_custom_field_method_id').value.should === method_id
  end

  it('Edit a custom field type') do
    index_url   = CustomFields::Controller::CustomFieldTypes.r(:index).to_s
    edit_url    = CustomFields::Controller::CustomFieldTypes.r(:edit).to_s
    save_button = lang('custom_field_types.buttons.save')
    method_id   = CustomFields::Model::CustomFieldMethod[
      :name => 'textarea'
    ].id.to_s

    visit(index_url)
    click_link('Spec type')

    current_path.should =~ /#{edit_url}\/\d+/

    # Update the form
    within('#custom_field_type_form') do
      fill_in('form_name', :with => 'Spec type modified')

      fill_in(
        'form_language_string',
        :with => 'custom_fields.special.type_hash.textarea'
      )

      fill_in('form_html_class', :with => 'spec_class_modified')
      select('textarea'       , :from => 'custom_field_method_id')

      click_on(save_button)
    end

    # Validate the results
    current_path.should =~ /#{edit_url}\/\d+/

    page.find_field('form_name').value.should      === 'Spec type modified'
    page.find_field('form_html_class').value.should === 'spec_class_modified'

    page.find_field('form_language_string') \
      .value.should === 'custom_fields.special.type_hash.textarea'

    page.find_field('custom_field_method_id').value.should === method_id
  end

  it('Edit a custom field type with invalid data') do
    index_url   = CustomFields::Controller::CustomFieldTypes.r(:index).to_s
    edit_url    = CustomFields::Controller::CustomFieldTypes.r(:edit).to_s
    save_button = lang('custom_field_types.buttons.save')

    visit(index_url)
    click_link('Spec type')

    current_path.should =~ /#{edit_url}\/\d+/

    within('#custom_field_type_form') do
      fill_in('form_name', :with => '')
      click_on(save_button)
    end

    page.has_selector?('span.error').should === true
  end

  it('Try to delete a field type without a specified ID') do
    index_url     = CustomFields::Controller::CustomFieldTypes.r(:index).to_s
    delete_button = lang('custom_field_types.buttons.delete')
    type_id       = CustomFields::Model::CustomFieldType[
      :name => 'Spec type modified'
    ].id

    visit(index_url)
    click_on(delete_button)

    page.has_selector?("input[id=\"custom_field_type_#{type_id}\"]") \
      .should === true
  end

  it('Delete a custom field type') do
    index_url     = CustomFields::Controller::CustomFieldTypes.r(:index).to_s
    delete_button = lang('custom_field_types.buttons.delete')
    rows          = CustomFields::Model::CustomFieldType.count - 1
    type_id       = CustomFields::Model::CustomFieldType[
      :name => 'Spec type modified'
    ].id

    visit(index_url)

    # Find the correct checkbox
    check("custom_field_type_#{type_id}")

    click_on(delete_button)

    page.has_content?('Spec type modified').should === false
    page.all('table tbody tr').count.should        === rows
  end
end # describe
