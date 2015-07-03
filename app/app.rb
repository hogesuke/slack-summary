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

before %r{^/(?!auth).*$} do
  headers({'Content-Type' => 'application/json'})

  if session[:user_id]
    @user = User.find(session[:user_id])
  end
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

  session[:token]   = auth_res[:credentials][:token]
  session[:user_id] = user.id
  session[:team_id] = auth_res[:info][:team_id]

  redirect(settings.root)
end

# todo このエンドポイントいるっけ？
get '/users' do
  fetch_slack_api('users.list').to_json
end

# todo
get '/users/:id' do
  User.where(:id => params['id'], :slack_channel_id => session[:team_id]).to_json
end

# todo
get '/channels' do
 fetch_slack_api('channels.list').to_json
end

# todo
get '/channels/:id' do

  users = fetch_slack_api('users.list')['members']

  # todo ペジネーション必要
  history = fetch_slack_api('channels.history', "channel=#{params['id']}")

  messages = history['messages']

  messages.each do |m|
    user_id = m['user']

    user = users.find do |u|
      u['id'] == user_id
    end

    if user
      m['user'] = { :id => user['id'], :name => user['name'] }
    end
  end

  messages.to_json
end

# todo
get '/articles' do
  # todo ページネーション
  Article.where(:slack_channel_id => session[:team_id]).to_json
end

# todo
get '/articles/:id' do
  # todo ページネーション
  Article.where(:slack_channel_id => session[:team_id], :id => params['id']).to_json
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

  JSON.parse(res.body)
end
