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
    store(mysqldump)
    cleanup
  end

  def store dump
    unless dump.empty?
      puts "Storing backup ..."
      begin
        set_storage_name
        Storage.files.create({
          body: dump,
          key:  dump_name
        })
        puts "Yay! Your backup successfully stored!"
        cleanup
      rescue => e
        puts "Oops! Something went wrong while storing: #{e}"
      end
    end
  end

  def cleanup
    set_storage_name
    files = Storage.files
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
    "#{db_name}_dump_#{Time.now.strftime('%d%m%Y%H%M')}.sql"
  end

  def mysqldump
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

  def set_storage_name
    Storage.name = dir_postfix
  end
end