# coding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
require 'json'
require 'active_record'
require 'yaml'
require 'omniauth'
require 'omniauth-slack'
require 'pp'
require_relative 'model/user'
require_relative 'model/article'
require_relative 'model/message'

ActiveRecord::Base.configurations = YAML.load_file(File.join(__dir__, './db/database.yml'))
ActiveRecord::Base.establish_connection(settings.environment)

configure :production, :development do
  config = YAML.load_file(File.join(__dir__, './config/config.yml'))

  set :client_id, config['client_id']
  set :client_secret, config['client_secret']
  set :sessions, true
  set :inline_templates, true # todo あとで消す

  # todo あとでこのへんskimiiを参考に修正する
  use Rack::Session::Cookie,
      :key          => 'rack.session',
      :expire_after => 60 * 60 * 24 * 30 # 30days

  set :protection, :except => [:json_csrf]
end

configure :development do
  set :server, 'webrick'
end

use OmniAuth::Builder do
  provider :slack, settings.client_id, settings.client_secret, scope: 'client'
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb "<a href='/auth/slack'>Login with Slack</a><br>"
end


get '/auth/:provider/callback' do
  result = request.env['omniauth.auth']
  erb "<a href='/'>Top</a><br>
         <h1>#{params[:provider]}</h1>
         <pre>#{JSON.pretty_generate(result)}</pre>"
end

# todo
get '/users' do
end

# todo
get '/users/:id' do
end

# todo
get '/channels' do
end

# todo
get '/channels/:id' do
end

# todo
get '/articles' do
end

# todo
get '/articles/:id' do
end

# todo
post '/articles' do
  user = User.new
  user.slack_id = 'ABCDEF'
  user.name = 'hogehoge'

  user.save
end

# todo
put '/articles/:id' do
end

# todo
delete '/articles/:id' do
end
