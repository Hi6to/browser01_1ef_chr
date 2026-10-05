# coding: utf-8
require 'socket'
socket = TCPSocket.new('127.0.0.1', 2000) #127.0.0.1の 2000番ポートのサーバに接続
puts socket.gets #サーバから受信した文字列を示
socket.puts 'Hello, server' #サーバへ文字列を送信
socket.close #サーバとの通信を切断
