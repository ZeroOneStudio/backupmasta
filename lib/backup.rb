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

  belongs_to :user

  def self.create params, current_user
    backup = new(params)
    backup.user = current_user
    if backup.save
      backup.set_storage_name
      Storage.create
    end
  end

  def self.destroy_with_directory id
    backup = Backup.get(id)
    if backup.destroy
      backup.set_storage_name
      Storage.destroy
    end
  end

  def perform
    store(dump)
    cleanup
  end

  def perform_async
    BackupWorker.perform_async(self.id)
  end

  def store db_dump
    unless db_dump.empty?
      puts "Storing backup ..."
      begin
        files.create({
          body: db_dump,
          key:  dump_name
        })
        puts "Yay! Your backup successfully stored!"
      rescue => e
        puts "Oops! Something went wrong while storing: #{e}"
      end
    end
  end

  def cleanup
    count = files.count
    if count > keep_limit
      puts "Cleaning up ..."
      files.shift(count - keep_limit).map do |file| 
        file.destroy
        puts "Backup #{file.key} was removed"
      end
    else
      puts "Nothing to cleanup"
    end
  end

  def dump_name
    time = Time.now
    "#{time.to_i}_#{db_name}_dump_#{time.strftime('%d_%B_%Y_%H_%M')}.sql"
  end

  def dump
    puts "Logging in ..."
 
    Net::SSH.start(host, ssh_user, key_data: [ENV['SSH_PRIVATE_KEY']], keys_only: TRUE) do |ssh|
      puts "Starting backup ..."
 
      stderr = ""
      stdout = ""
      
      ssh.exec!("mysqldump --user=#{db_user} --password=#{db_password} #{db_name}") do |channel, stream, data|
        if stream == :stderr
          stderr << data
          puts "Something went wrong while dumping: #{stderr}"
        elsif stream == :stdout
          stdout << data
        end
      end

      puts "Done!" if stderr.empty?
      return stdout
    end
  end

  def latest  
    files.empty? ? nil : files.last
  end

  def files
    set_storage_name
    Storage.files
  end

  def set_storage_name
    Storage.name = dir_postfix
  end

  def owner? current_user
    user == current_user
  end
end