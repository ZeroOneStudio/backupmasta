task :environment do
  require './app.rb'
end

desc "Perform backups"
task :backup => :environment do
  Backup.all.map(&:perform)
end