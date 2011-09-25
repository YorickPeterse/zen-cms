require File.expand_path('../../../helper', __FILE__)
require __DIR__('../../fixtures/zen/theme/theme')
require 'fileutils'

describe('Zen::Controller::MainController') do
  behaves_like :capybara

  after do
    # Let's make sure the 404 template is back where it belongs.
    template = File.join(Zen::Theme[:spec_theme].template_dir, '404.xhtml')
    old      = template + '.old'

    if File.exist?(old) and !File.exist?(template)
      FileUtils.mv(old, template)
    end
  end

  # Set the default section/template group to use.
  it('Create the test data') do
    section = Sections::Model::Section.create(
      :name                    => 'Default section',
      :slug                    => 'default-section',
      :comment_allow           => false,
      :comment_require_account => false,
      :comment_moderate        => false,
      :comment_format          => 'plain'
    )

    plugin(:settings, :get, :default_section).value = section.id
    plugin(:settings, :get, :theme).value           = 'spec_theme'

    section.name.should === 'Default section'
    section.slug.should === 'default-section'

    plugin(:settings, :get, :theme).value.should === 'spec_theme'
  end

  it('Request the homepage') do
    visit('/')

    page.body.include?('This is the homepage.').should === true
  end

  it('Request a page without a theme set') do
    plugin(:settings, :get, :theme).value = nil

    visit('/')

    page.body.include?(lang('zen_general.errors.no_theme')).should === true

    plugin(:settings, :get, :theme).value = 'spec_theme'
  end

  it('Request a non existing template') do
    visit('/does-not-exist')

    page.body.include?('The requested page could not be found!') \
      .should === true

    page.status_code.should === 404
  end

  it('Request a non existing template without a 404 template') do
    template = File.join(
      Zen::Theme[:spec_theme].template_dir,
      '404.xhtml'
    )

    FileUtils.mv(template, template + '.old')

    visit('/does-not-exist')

    page.body.include?(lang('zen_general.errors.no_templates')) \
      .should === true

    page.status_code.should === 404

    FileUtils.mv(template + '.old', template)
  end

  # Reset the default section and remove it
  it('Remove all the test data') do
    Sections::Model::Section.destroy

    plugin(:settings, :get, :default_section).value = nil
    plugin(:settings, :get, :theme).value           = nil

    Sections::Model::Section[:slug => 'default-section'].nil?.should === true
  end
end
