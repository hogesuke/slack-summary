# coding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
require 'json'
require 'active_record'
require 'yaml'
require 'pp'

ActiveRecord::Base.configurations = YAML.load_file(File.join(__dir__, './db/database.yml'))
ActiveRecord::Base.establish_connection(settings.environment)

configure :production, :development do

  use Rack::Session::Cookie,
      :key          => 'rack.session',
      :expire_after => 60 * 60 * 24 * 30 # 30days

  set :protection, :except => [:json_csrf]
end

configure :development do
  set :server, 'webrick'
end

before %r{^/(?!auth).*$} do
end

after do
  ActiveRecord::Base.connection.close
end

get '/user' do
  pp 'user'
end