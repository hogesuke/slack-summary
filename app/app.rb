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

  set :root_url, config['root_url']

  # todo あとでこのへんskimiiを参考に修正する
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

  redirect(settings.root_url)
end

# todo
get '/users' do
end

# todo
get '/users/:id' do
end

# todo
get '/channels' do
  uri = URI.parse('https://slack.com/api/channels.list?token=' + session[:token])

  # todo beginはなくしたいね
  begin
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end

    case res
      when Net::HTTPSuccess
        # channnels = JSON.parse(res.body)
      else
        status(res.code)
        # todo エラーメッセージの詰め方ももう少しうまくやりたい。かならずrescueでreturnするとか。
        return {err_msg: 'channelsの取得に失敗しました'}.to_json
    end
  rescue => e
    status('400')
    return {err_msg: 'channelsの取得に失敗しました'}.to_json
  end

  return res.body
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
end

# todo
put '/articles/:id' do
end

# todo
delete '/articles/:id' do
end
