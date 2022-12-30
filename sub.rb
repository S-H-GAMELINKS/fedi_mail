require 'mastodon'
require 'dotenv'
require 'logger'

# 環境変数の読み込み
Dotenv.load

# ロガーの生成
logger = Logger.new(STDERR)

# 投稿のトリミング処理
def trim_content(content)
    content.gsub(/<p>|<\/p>|<span>|<\/span>|<span class="h-card"><a href="#{ENV['MASTODON_URL']}\/@fedi_mail" class="u-url mention" rel="nofollow noopener noreferrer" target="_blank">|<span class="h-card"><a href="#{ENV['MASTODON_URL']}\/@fedi_mail" class="u-url mention">/, '')
        .sub(/@fedi_mail<\/a>/, '')
        .gsub(/<br \/>/, '')
end

# BotのID
bot_id = ENV['BOT_ID']

loop do
    begin
        # クライアントを初期化
        client = Mastodon::REST::Client.new(base_url: ENV['MASTODON_URL'], bearer_token: ENV['ACCESS_TOKEN'])

        client.notifications.each do |notification|
            # メンション以外の場合はスキップ
            next if notification.type != 'mention'

            # メンションのStatusを取得
            status = notification.status

            next if status.visibility != 'direct'

            # DMで受け取った内容を正規表現でTrim
            content = trim_content(status.content)

            # フォロワーを取得
            follower = client.followers(bot_id, limit: 2000000).to_a.sample

            client.create_status("@#{follower.acct}\n#{content}", visibility: 'direct')
        end

        # 通知の削除
        client.clear_notifications

        # 遅延処理
        sleep(3)
    rescue => e
        logger.error("Error!")
        logger.error(e.full_message)
    end
end