desc "Perform backups"
task :backup  => :environment do
  Backup.all.map do |backup|
    backup.perform
  end
end