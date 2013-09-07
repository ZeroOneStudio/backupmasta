require 'sinatra'
require 'data_mapper'
require 'fog'
require 'net/ssh'
require 'json'
require 'omniauth'
require 'omniauth-github'

require_relative "lib/backup"
require_relative "lib/user"
require_relative "lib/storage"

enable :sessions

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data/#{Sinatra::Base.environment}.db")
DataMapper.finalize.auto_upgrade!

Storage.connect

use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end

get '/auth/:provider/callback' do
  user = User.create_from_omniauth(request.env["omniauth.auth"])
  session[:user_id] = user.id
  redirect '/'
end

get '/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/' do
  erb :index
end

post '/backups' do
  backup = Backup.new(params[:backup])
  backup.user = current_user
  backup.save
  redirect '/'
end

get '/backups/:id/perform' do
  b = Backup.get(params[:id])
  b.store
  redirect '/'
end

helpers do
  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end
end