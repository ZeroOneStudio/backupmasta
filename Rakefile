desc "Perform backups"
task :backup do
  Backup.all.map(&:perform)
end