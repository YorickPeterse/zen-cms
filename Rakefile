task_path = File.expand_path('../lib/zen/task', __FILE__)
tasks     = ['build', 'clean', 'proto', 'setup', 'test', 'spelling']

tasks.each do |task|
  import File.join(task_path, "#{task}.rake")
end
