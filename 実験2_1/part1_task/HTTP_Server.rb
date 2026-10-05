# coding: utf-8
require 'socket'

server = TCPServer.new 2000
loop do
    client = server.accept
    headers = []
    while header = client.gets
        break if header.chomp.empty?
        headers << header.chomp
    end
    p headers
    client.puts "HTTP/1.0 200 OK"
    client.puts "Content-Type: text/html"
    client.puts
    client.puts "<h1>Hello, World!</h1><h2>Welcome!</h2><p>This is my personal
page!</p>"
    client.close
end 