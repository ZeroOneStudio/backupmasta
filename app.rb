require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/#{Sinatra::Base.environment}.db")

class Backup
  include DataMapper::Resource

  property :id, Serial
  property :user, String
  property :password, String
  property :host, String
  property :db_name, String
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
