require __DIR__('custom_fields/model/custom_field')
require __DIR__('custom_fields/model/custom_field_group')
require __DIR__('custom_fields/model/custom_field_value')
require __DIR__('custom_fields/controller/custom_field_groups')
require __DIR__('custom_fields/controller/custom_fields')

Zen::Package.add do |p|
  p.name          = 'Custom Fields'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "The Custom Fields module is used to manage, how original, custom fields and custom field groups."
  p.identifier    = 'com.zen.custom_fields'
  p.directory     = __DIR__('custom_fields')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => "Custom Fields",
    :url   => "admin/custom-field-groups"
  }]
end
