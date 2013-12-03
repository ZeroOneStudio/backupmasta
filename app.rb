require 'sinatra'
require 'data_mapper'
require 'fog'
require 'unf'
require 'net/ssh'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'sidekiq'
require 'sidekiq/web'
require 'digest/md5'
require './env' if File.exists?('env.rb')

require_relative 'lib/backup'
require_relative 'lib/user'
require_relative 'lib/storage'
require_relative 'lib/workers/backup_worker'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
end

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
  if current_user
    erb :profile
  else
    erb :index
  end
end

post '/backups' do
  if current_user
    Backup.create(params[:backup], current_user)
    redirect '/'
  else
    halt 401, 'Not authorized!'
  end
end

get '/backups/:id/edit' do
  @backup = Backup.get(params[:id])
  if current_user && @backup.owner?(current_user)
    erb :"backups/edit"
  else
    halt 401, 'Not authorized!'
  end
end

put '/backups/:id' do
  backup = Backup.get(params[:id])
  if current_user && backup.owner?(current_user)
    redirect '/' if backup.update(params[:backup])
  else
    halt 401, 'Not authorized!'
  end
end

delete '/backups/:id' do
  if current_user && backup.owner?(current_user)
    Backup.destroy_with_directory(params[:id])
    redirect '/'
  else
    halt 401, 'Not authorized!'
  end
end

post '/backups/:id/perform' do
  backup = Backup.get(params[:id])
  if current_user && backup.owner?(current_user)
    backup.perform_async
    redirect '/'
  else
    halt 401, 'Not authorized!'
  end
end

helpers do
  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end
end