require File.expand_path('../../helper', __FILE__)
require File.expand_path('../../resources/plugin/spec', __FILE__)
require 'rdiscount'

describe("Zen::Plugin") do
  
  it("No plugins should be added") do
    lambda { Zen::Plugin[:foobar] }.should raise_error(Zen::PluginError)
  end

  it("Add a new plugin") do
    Zen::Plugin.add do |plugin|
      plugin.name    = 'spec'
      plugin.author  = 'Yorick Peterse'
      plugin.about   = 'A simple spec plugin'
      plugin.url     = 'http://zen-cms.com/'
      plugin.plugin  = SpecPlugin
    end

    Zen::Plugin::Registered.empty?.should  === false
    Zen::Plugin[:spec].name.should         === :spec
  end

  it("Retrieve a plugin by it's identifier") do
    plugin = Zen::Plugin[:spec]

    plugin.name.should   === :spec
    plugin.author.should === 'Yorick Peterse'
  end

  it("Execute a plugin") do
    response = plugin(:spec, :upcase, 'hello world')

    response.should === 'HELLO WORLD'
  end

end
