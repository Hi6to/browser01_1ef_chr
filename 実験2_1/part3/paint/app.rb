# coding: utf-8
# app.rb（発展課題）
# 複数のブラウザで同じキャンバスに絵を描ける共有お絵かきアプリ
#   GET / （通常のリクエスト）       : お絵かき画面（index.erb）を返す
#   GET / （WebSocket のリクエスト） : WebSocket で接続し，描いた線を全員に中継する
require 'sinatra'
require 'faye/websocket'
require 'json'

set :server, :puma     # WebSocket に対応した Puma で起動する
set :bind, '127.0.0.1'
set :port, 4567

clients = [] # 接続中のクライアント（WebSocket）の一覧
history = [] # これまでに描かれた線（後から接続した人にも同じ絵を表示するため）

get '/' do
  if Faye::WebSocket.websocket?(request.env)
    ws = Faye::WebSocket.new(request.env)

    # 接続されたとき：一覧に追加し，これまでに描かれた線をすべて送る
    ws.on :open do |event|
      clients << ws
      history.each { |msg| ws.send(msg) }
    end

    # メッセージを受け取ったとき
    ws.on :message do |event|
      data = JSON.parse(event.data) rescue nil
      next unless data.is_a?(Hash)

      case data['type']
      when 'line'
        # 線の座標と色を受け取る（数値と色の形式を確認してから中継する）
        color = data['color'].to_s
        color = '#000000' unless color.match?(/\A#[0-9a-fA-F]{6}\z/)
        msg = JSON.generate(type: 'line',
                            x0: data['x0'].to_f, y0: data['y0'].to_f,
                            x1: data['x1'].to_f, y1: data['y1'].to_f,
                            color: color)
        history << msg
        # 描いた本人は既に自分の画面に描いているので，それ以外の全員に送る
        clients.each { |c| c.send(msg) unless c == ws }
      when 'clear'
        # 全消去：履歴を消し，本人も含めた全員に全消去を指示する
        history.clear
        msg = JSON.generate(type: 'clear')
        clients.each { |c| c.send(msg) }
      end
    end

    # 切断されたとき：一覧から取り除く
    ws.on :close do |event|
      clients.delete(ws)
    end

    ws.rack_response # WebSocket 接続を確立するためのレスポンスを返す
  else
    erb :index
  end
end
