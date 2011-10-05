namespace :plugin do
  desc 'Lists all installed plugins'
  task :list do
    Zen::Plugin::Registered.each do |name, plugin|
      if plugin.about.nil? or plugin.about.empty?
        puts "* #{name}"
      else
        puts "* #{name}\n  #{plugin.about}"
      end
    end
  end
end
