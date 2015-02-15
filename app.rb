require 'sinatra'
require 'active_support/deprecation'
require 'sinatra_more/markup_plugin'
require 'sinatra_more/render_plugin'
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

register SinatraMore::MarkupPlugin
register SinatraMore::RenderPlugin

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
end

STORAGE = Storage.connect unless Sinatra::Base.test?

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/data/#{Sinatra::Base.environment}.db")
DataMapper.finalize.auto_upgrade!

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
  current_user ? erb(:profile) : erb(:index)
end

post '/backups' do
  halt 401, 'Not authorized!' unless current_user
  Backup.create(params[:backup], current_user)
  redirect '/'
end

get '/backups/:id/edit' do
  perform_action do |backup|
    erb :"backups/edit"
  end
end

put '/backups/:id' do
  perform_action do |backup|
    redirect '/' if backup.update(params[:backup])
  end
end

delete '/backups/:id' do
  perform_action do |backup|
    backup.destroy_with_directory
    redirect '/'
  end
end

post '/backups/:id/perform' do
  perform_action do |backup|
    backup.perform_async
    redirect '/'
  end
end

def perform_action &block
  @backup = Backup.get(params[:id])
  if current_user && @backup.owner?(current_user)
    yield @backup if block_given?
  else
    halt 401, 'Not authorized!'
  end
end

helpers do
  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end
end
