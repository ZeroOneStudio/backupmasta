require 'sinatra'
require 'data_mapper'
require 'fog'
require 'net/ssh'
require 'json'

require_relative "lib/backup"
require_relative "lib/storage"

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data/#{Sinatra::Base.environment}.db")
DataMapper.finalize.auto_upgrade!

Storage.connect

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
  b.store
  redirect '/'
end