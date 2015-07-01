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

  # todo エラーテスト用 あとで消す
  # set :environment, :production

  set :client_id, config['client_id']
  set :client_secret, config['client_secret']
  set :sessions, true
  set :inline_templates, true # todo あとで消す

  set :root, config['root']
  set :slack_root, config['slack_root']

  use Rack::Session::Cookie,
      :key          => 'rack.session',
      :expire_after => 60 * 60 * 24 * 30, # 30days
      :secret       => config['session_secret']

  set :protection, :except => [:json_csrf]
end

configure :development do
  set :server, 'webrick'
end

use OmniAuth::Builder do
  # todo 権限レベル設定できるかな？
  # todo なんかwarningでてる
  provider :slack, settings.client_id, settings.client_secret, scope: 'client'
end

after do
  ActiveRecord::Base.connection.close
end

error do
  { err_msg: env['sinatra.error'].message }.to_json
end

get '/auth/:provider/callback' do
  auth_res = request.env['omniauth.auth']

  user = User.where(:slack_user_id => auth_res[:uid]).first

  unless user
    user = User.new
    user.slack_user_id = auth_res[:uid]
    user.name = auth_res[:info][:user]
    user.save # todo saveに失敗した場合
  end

  session[:token] = auth_res[:credentials][:token]
  session[:user_id] = user.id

  redirect(settings.root)
end

# todo
get '/users' do
  fetch_slack_api('users.list')
end

# todo
get '/users/:id' do
end

# todo
get '/channels' do
 fetch_slack_api('channels.list')
end

# todo
get '/channels/:id' do
  # todo ペジネーション必要だね…
  fetch_slack_api('channels.history', "channel=#{params['id']}")
end

# todo
get '/articles' do
end

# todo
get '/articles/:id' do
end

# todo
post '/articles' do
end

# todo
put '/articles/:id' do
end

# todo
delete '/articles/:id' do
end

def fetch_slack_api(method, query = '')

  if not query.nil? and not query.start_with?('&')
    query = '&' + query
  end

  uri = URI.parse(settings.slack_root + method + '?token=' + session[:token] + query)

  begin
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
  rescue
    status(400)
    raise("#{method}の取得に失敗しました")
  end

  unless res.is_a?(Net::HTTPSuccess)
    status(res.code)
    fail("#{method}の取得に失敗しました")
  end

  res.body
end
