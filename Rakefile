task :environment do
  require 'active_support/deprecation'
  require './app.rb'
end

desc "Perform backups"
task :backup => :environment do
  begin
    Backup.enabled.map(&:perform_async)
  rescue => e
    puts "Got an error: #{e}"
    Rake::Task[:backup].reenable
    Rake::Task[:backup].invoke
  end
end

begin
  require "rspec/core/rake_task"

  desc "Run specs"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w[--color]
    t.pattern = 'spec/**/*_spec.rb'
  end
  task :default => :spec
rescue LoadError
end