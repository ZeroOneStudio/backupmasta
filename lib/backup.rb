class Backup
  include DataMapper::Resource

  property :id, Serial
  property :ssh_user, String
  property :host, String
  property :db_user, String
  property :db_name, String
  property :db_password, String
  property :keep_limit, Integer

  belongs_to :user

  def store
    dump = mysqldump
    unless dump.empty?
      puts "Storing backup ..."
      begin
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
 
    Net::SSH.start(host, ssh_user) do |ssh|
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
end