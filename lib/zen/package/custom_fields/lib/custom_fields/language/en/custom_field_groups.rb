# encoding: utf-8

Zen::Language::Translation.add do |t|
  t.language = 'en'
  t.name     = 'custom_field_groups'

  t['titles.index'] = 'Custom Field Groups'
  t['titles.edit']  = 'Edit Custom Field Group'
  t['titles.new']   = 'Add Custom Field Group'

  t['labels.id']            = '#'
  t['labels.name']          = 'Name'
  t['labels.description']   = 'Description'
  t['labels.sections']      = 'Sections'
  t['labels.manage_fields'] = 'Manage custom fields'
  t['labels.none']          = 'None'

  t['messages.no_groups'] = 'No custom field groups were found.'

  t['errors.new']           = 'Failed to create a new custom field group.'
  t['errors.save']          = 'Failed to modify the custom field group.'
  t['errors.delete']        = 'Failed to delete the custom field group ' \
    'with ID #%s'
  t['errors.no_delete']     = 'You haven\'t specified any custom field ' \
    'groups to delete'
  t['errors.invalid_group'] = 'The specified custom field group is invalid.'

  t['success.new']    = 'The custom field group has been created.'
  t['success.save']   = 'The custom field group has been modified.'
  t['success.delete'] = 'The selected custom field groups have been deleted.'

  t['buttons.new']    = 'Add group'
  t['buttons.delete'] = 'Delete selected groups'
  t['buttons.save']   = 'Save group'

  t['permissions.show']   = 'Show field group'
  t['permissions.edit']   = 'Edit field group'
  t['permissions.new']    = 'Add field group'
  t['permissions.delete'] = 'Delete field group'
end
