require 'coveralls'
Coveralls.wear!

ENV['RACK_ENV'] = 'test'
ENV['SESSION_SECRET'] = '355fuck431ddasdasd0f3d84qwe118ca8ba018'
ENV['GOOGLE_STORAGE_ID'] = 'fake_storage_id'
ENV['GOOGLE_STORAGE_SECRET'] = 'fake_storage_secret'

require './app.rb'
require 'rack/test'

set :run, false
set :raise_errors, true
set :logging, false

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
