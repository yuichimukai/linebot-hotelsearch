class LineBotController < ApplicationController
  protect_from_forgery except:[:callback]

  def callback
  end

  private 
    #LINE Messaging API SDKの機能を使えるようにLine::Bot::Clientをインスタンス化するclientメソッドを作成
    def client
      #インスタンス変数@clientが定義された瞬間は中身がnilなため右辺が実行されインスタンスが@clientに代入される
      #2回目は@clientに既にインスタンスが入っているため右辺は実行されない
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
end
