require File.expand_path('../../lib/zen', __FILE__)
require 'rspec'
require 'rack/test'
require 'capybara'
require 'capybara/rspec'

# Configure all middlewares
Ramaze.middleware! :spec do |m|
  m.run(Ramaze::AppMap)
end

# Update all paths
Ramaze.options.roots = [__DIR__]
Ramaze.options.mode  = :spec
Zen.options.root     = __DIR__

Zen::Language.options.paths.push(__DIR__('resources'))

# Configure the database
Zen::Database.mode :spec do |db|
  db.adapter  = 'sqlite'
  db.database = __DIR__('resources/database.db') 
end

# Start Zen
Zen.init

# Require all packages
require __DIR__('../lib/zen/package/all')

# Configure Capybara
Capybara.configure do |config|
  config.default_driver = :rack_test
  config.default_host   = 'localhost'
  config.app            = Ramaze  
end

# Start ramaze
Ramaze.start(
  :root    => Ramaze.options.roots,
  :started => true,
  :port    => Ramaze::Adapter.options.port
)

# Configure RSpec
RSpec.configure do |c|
  # Clear all logging done by Ramaze as this makes reading the RSpec output a bit hard
  c.after do
    ::Ramaze::Log.loggers.clear
  end

  # Automatically log the user in
  c.before(:auto_login => true) do
    login_url     = ::Users::Controller::Users.r(:login).to_s
    dashboard_url = ::Sections::Controller::Sections.r(:index).to_s

    visit(login_url)
    ::Ramaze::Log.loggers.clear

    within('#login_form') do
      fill_in 'Email'   , :with => 'spec@domain.tld'
      fill_in 'Password', :with => 'spec'
      click_button 'Login'
    end
  end
end

# Hash that can be used to store test data for certain specifications
Testdata = {}
