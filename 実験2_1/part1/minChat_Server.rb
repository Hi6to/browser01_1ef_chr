# coding: utf-8
require 'socket'

server = TCPServer.new 2000 # 2000番ポートにサーバを立てる

# クライアントの受付開始
client = server.accept

# クライアントから文字列を受信して表示
loop do
  message = client.gets

  break if message.nil?

  message = message.chomp
  puts message

  # byeを受信したら通信を終了
  break if message == 'bye'
end

client.close
server.close
