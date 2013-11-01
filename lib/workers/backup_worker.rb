class BackupWorker
  include Sidekiq::Worker

  def perform(backup_id)
    backup = Backup.get(backup_id)
    backup.perform
  end
end