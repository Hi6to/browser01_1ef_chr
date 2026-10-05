# coding: utf-8
require 'socket'

socket = TCPSocket.new('127.0.0.1', 2000)

# 標準入力から文字列を受け取りサーバへ送信
loop do
  message = gets

  break if message.nil?

  socket.puts message.chomp

  # byeを送信したら通信を終了
  break if message.chomp == 'bye'
end

socket.close
