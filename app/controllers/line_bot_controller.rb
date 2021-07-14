class LineBotController < ApplicationController
  protect_from_forgery except:[:callback]

  def callback
    #リクエストのメッセージボディを参照
    #readで文字列として取得
    body = request.body.read
    #署名の検証のためヘッダーを参照する
    #HTTP_X_LINE_SIGNATUREに署名が格納されている
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    #署名検証
    unless client.validate_signature(body, signature)
      #headメソッドはステータスコードを返すために使用
      return head :bad_request
    end
    events = client.parse_events_from(body)
    events.each do |event|
      case event
      #ユーザーがメッセージ送信したことを示すイベントかどうか確認
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    head :ok
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
