task :environment do
  require './app.rb'
end

desc "Perform backups"
task :backup => :environment do
  begin
    Backup.all.map(&:perform_async)
  rescue => e
    puts "Got an error: #{e}"
    Rake::Task[:backup].reenable
    Rake::Task[:backup].invoke
  end
end