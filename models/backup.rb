require 'net/ssh'

class Backup
  include DataMapper::Resource

  property :id, Serial
  property :ssh_user, String
  property :ssh_password, String
  property :db_host, String
  property :db_user, String
  property :db_name, String
  property :db_password, String

  def perform_backup
    puts "Logging in ..."
    Net::SSH.start(db_host, ssh_user, password: ssh_password) do |ssh|
      dump_name = "#{db_name}_dump_#{Time.now.strftime('%d_%m_%Y_%H_%M')}"
      mysqldump_command = "mysqldump --user=#{db_user} --password=#{db_password} #{db_name} > #{dump_name}.sql"
      
      puts "Starting backup ..."

      stderr = ""
      ssh.exec!(mysqldump_command) do |channel, stream, data|
        stderr << data if stream == :stderr
      end

      if stderr.empty?
       puts "Done!"
      else
       puts stderr
      end
    end
  end
end