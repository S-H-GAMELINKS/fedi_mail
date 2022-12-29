require 'sinatra'
require 'sinatra/flash'
require 'mastodon'
require 'dotenv'

# 環境変数の読み込み
Dotenv.load

# セッションの有効化
enable :sessions

get '/' do
    erb :index  
end

post '/confirm' do
    # BotのID
    bot_id = ENV['BOT_ID']

    # クライアントを初期化
    client = Mastodon::REST::Client.new(base_url: ENV['MASTODON_URL'], bearer_token: ENV['ACCESS_TOKEN'])

    # フォロワーを取得
    follower = client.followers(bot_id, limit: 2000000).to_a.sample

    client.create_status("@#{follower.acct}\n#{params[:content]}", visibility: 'direct')

    flash[:notice] = "メッセージを届けました"
    redirect '/'
end
