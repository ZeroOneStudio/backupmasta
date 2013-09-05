require 'sinatra'
require 'data_mapper'

require_relative "models/backup"

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/#{Sinatra::Base.environment}.db")
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