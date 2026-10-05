# coding: utf-8
require 'socket'
server = TCPServer.new 2000 #2000 番ポートにサーバを立てる
#クライアントの受付開始
client = server.accept
#サーバのプログラムは，クライアントからのリクエストがあるまでここで一時停止（ブロッキングします）
client.puts 'Hello, client' #クライアントへ文字列を送信
puts client.gets #クライアントから受信した文字列を表示
client.close #クライアントとの通信を切断
