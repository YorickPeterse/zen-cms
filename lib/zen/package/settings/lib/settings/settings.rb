Settings::Setting.add do |setting|
  setting.title       = 'settings.labels.website_name'
  setting.description = 'settings.placeholders.website_name'
  setting.name        = 'website_name'
  setting.group       = 'general'
  setting.default     = 'Zen'
  setting.type        = 'textbox'
end

Settings::Setting.add do |setting|
  setting.title       = 'settings.labels.website_description'
  setting.description = 'settings.placeholders.website_description'
  setting.name        = 'website_description'
  setting.group       = 'general'
  setting.type        = 'textarea'
end

Settings::Setting.add do |setting|
  setting.title       = 'settings.labels.language'
  setting.description = 'settings.placeholders.language'
  setting.name        = 'language'
  setting.group       = 'general'
  setting.default     = 'en'
  setting.type        = 'select'
  setting.values      = Zen::Language::Languages
end

Settings::Setting.add do |setting|
  setting.title       = 'settings.labels.frontend_language'
  setting.description = 'settings.placeholders.frontend_language'
  setting.name        = 'frontend_language'
  setting.group       = 'general'
  setting.default     = 'en'
  setting.type        = 'select'
  setting.values      = Zen::Language::Languages
end

Settings::Setting.add do |setting|
  setting.title       = 'settings.labels.theme'
  setting.description = 'settings.placeholders.theme'
  setting.name        = 'theme'
  setting.group       = 'general'
  setting.type        = 'select'
  setting.values      = lambda do
    theme_hash = {}

    Zen::Theme::Registered.each do |name, theme|
      name             = name.to_s
      theme_hash[name] = name
    end

    return theme_hash
  end
end

Settings::Setting.add do |setting|
  setting.title       = 'settings.labels.date_format'
  setting.description = 'settings.placeholders.date_format'
  setting.name        = 'date_format'
  setting.group       = 'general'
  setting.type        = 'select'
  setting.default     = '%Y-%m-%d %H:%M:%S'
  setting.values      = {
    '%Y-%m-%d %H:%M:%S' => '2011-05-10 13:30:12',
    '%d-%m-%Y %H:%M:%S' => '10-05-2011 13:30:12',
    '%A, %B %d, %Y'     => 'Tuesday, May 10, 2011'
  }
end

Settings::Setting.add do |setting|
  setting.title       = 'settings.labels.enable_antispam'
  setting.description = 'settings.placeholders.enable_antispam'
  setting.name        = 'enable_antispam'
  setting.group       = 'security'
  setting.type        = 'radio'
  setting.values      = {
    lang('zen_general.special.boolean_hash.true')  => '1',
    lang('zen_general.special.boolean_hash.false') => '0'
  }
end
