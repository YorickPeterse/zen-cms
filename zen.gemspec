require_relative('../lib/zen/base/version')

# Get all the files from the manifest
manifest = File.open './MANIFEST', 'r'
manifest = manifest.read.strip
manifest = manifest.split "\n"

Gem::Specification.new do |s|
  s.name        = 'zen'
  s.version     = Zen::Version
  s.date        = '27-03-2011'
  s.authors     = ['Yorick Peterse']
  s.email       = 'info@yorickpeterse.com'
  s.summary     = 'Zen is a fully modular CMS written using Ramaze.'
  s.homepage    = 'http://zen-cms.com/'
  s.description = 'Zen is a fully modular CMS written using Ramaze. Unlike traditional Content Management Systems you are completely free to build whatever you want.'
  s.files       = manifest
  s.has_rdoc    = 'yard'
  s.executables = ['zen']
  
  ##
  # The following gems are *always* required 
  #
  s.add_dependency('sequel'           , ['>= 3.20.0'])
  s.add_dependency('ramaze'           , ['>= 2011.01.30'])
  s.add_dependency('bcrypt-ruby'      , ['>= 2.1.4'])
  s.add_dependency('liquid'           , ['>= 2.2.2'])
  s.add_dependency('json'             , ['>= 1.5.1'])
  s.add_dependency('thor'             , ['>= 0.14.6'])
  s.add_dependency('defensio'         , ['>= 0.9.1'])
  s.add_dependency('sequel_sluggable' , ['>= 0.0.6'])
  s.add_dependency('ruby-extensions'  , ['>= 1.0'])

  ##
  # These gems are only required when hacking the Zen core or when running tests.
  #
  s.add_development_dependency('rdiscount', ['>= 1.6.8'])
  s.add_development_dependency('redcloth' , ['>= 4.2.7'])
  s.add_development_dependency('rspec'    , ['>= 2.5.0'])
  s.add_development_dependency('yard'     , ['>= 0.6.5'])
  s.add_development_dependency('capybara' , ['>= 0.4.1.2'])
  s.add_development_dependency('rack-test')
  s.add_development_dependency('sqlite3')
end
