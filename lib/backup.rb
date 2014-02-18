class Backup
  include DataMapper::Resource

  property :id, Serial
  property :ssh_user, String, required: true
  property :host, String, required: true
  property :db_user, String, required: true
  property :db_name, String, required: true
  property :db_password, String, required: true
  property :keep_limit, Integer, required: true
  property :dir_postfix, String, required: true, unique: true
  property :enabled, Boolean

  belongs_to :user

  def self.enabled
    all(enabled: true)
  end

  def self.create params, current_user
    backup = new(params)
    backup.user = current_user
    backup.set_storage_name { STORAGE.create } if backup.save
  end

  def destroy_with_directory
    set_storage_name { STORAGE.destroy } if destroy
  end

  def perform
    store(dump)
    cleanup
  end

  def perform_async
    BackupWorker.perform_async(self.id)
  end

  def store db_dump
    files.create({ body: db_dump, key:  dump_name }) if db_dump
  end

  def cleanup
    files.shift(files_count - keep_limit).map {|file| file.destroy } if files_count > keep_limit
  end

  def dump_name
    time = Time.now
    "#{time.to_i}_#{db_name}_dump_#{time.strftime('%d_%B_%Y_%H_%M')}.sql"
  end

  def dump
    Net::SSH.start(host, ssh_user, key_data: [ENV['SSH_PRIVATE_KEY']], keys_only: TRUE) do |ssh|
      stdout = ""

      ssh.exec!("mysqldump --user=#{db_user} --password=#{db_password} #{db_name}") do |channel, stream, data|
        abort("Something went wrong while backing up:\n#{data}") if stream == :stderr
        stdout << data if stream == :stdout
      end

      return stdout
    end
  end

  def latest
    files.last unless files.empty?
  end

  def files_count
    files.count
  end

  def files
    set_storage_name { STORAGE.files }
  end

  def set_storage_name
    STORAGE.name = dir_postfix and yield
  end

  def owner? current_user
    user == current_user
  end
end