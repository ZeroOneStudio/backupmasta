require 'net/ssh'

class Backup
  include DataMapper::Resource

  property :id, Serial
  property :ssh_user, String
  property :host, String
  property :db_user, String
  property :db_name, String
  property :db_password, String

  def perform_backup
    puts "Logging in ..."
    Net::SSH.start(host, ssh_user) do |ssh|
      dump_name = "#{db_name}_dump_#{Time.now.strftime('%d_%m_%Y_%H_%M')}"
      mysqldump_command = "mysqldump --user=#{db_user} --password=#{db_password} #{db_name}"
      
      puts "Starting backup ..."

      stderr = stdout = ""
      ssh.exec!(mysqldump_command) do |channel, stream, data|
        stderr << data if stream == :stderr
        stdout << data if stream == :stdout
      end

      if stderr.empty?
        puts "`db_name` was successfully backed up!"
      else
        puts stderr
      end
    end
  end
end