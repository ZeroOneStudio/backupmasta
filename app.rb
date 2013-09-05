require 'sinatra'
require 'data_mapper'
require 'open4'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/#{Sinatra::Base.environment}.db")

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
    puts "Starting backing up..."
    pid, stdin, stdout, stderr = Open4::popen4 "ssh flops 'mysqldump --user=#{db_user} --password=#{db_password} #{db_name} > #{db_name}.sql'"
    stdin.close
    ignored, status = Process::waitpid2 pid
    if status.exitstatus == 0
      puts "Done!"
    else
      puts "Something went wrong: #{ stderr.read.strip }"
    end
  end
end

DataMapper.finalize.auto_upgrade!

get '/' do
  erb :index
end

post '/backups' do
  backup = Backup.new(params[:backup])
  backup.save
  redirect '/'
end

get '/backups/:id/perform' do
  b = Backup.get(params[:id])
  b.perform_backup
  redirect '/'
end