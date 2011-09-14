require 'fileutils'

# Task group used to remove various files that aren't needed when releasing gems
# and such.
namespace :clean do
  desc 'Removes all the gems located in pkg/'
  task :gem do
    glob_pattern = File.expand_path('../../../../pkg/*.gem', __FILE__)

    Dir.glob(glob_pattern).each do |gem|
      File.unlink(gem)
    end
  end

  desc 'Removes all YARD files'
  task :yard do
    zen_path = File.expand_path('../../../../', __FILE__)

    FileUtils.rm_rf("#{zen_path}/doc")
    FileUtils.rm_rf("#{zen_path}/.yardoc")
  end

  desc 'Removes all the minified assets'
  task :assets do
    path = File.expand_path('../../../../spec/public/minified/*', __FILE__)

    Dir.glob(path).each do |file|
      File.unlink(file)
    end
  end
end
