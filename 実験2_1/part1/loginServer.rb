# coding: utf-8
require 'webrick'

srv = WEBrick::HTTPServer.new({
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 2000
})

srv.mount_proc('/login') do |req, res|
  password = req.query['password']
  found = false

  f = File.open('List.txt', 'r')

  f.each_line do |line|
    line = line.chomp

    if password == line
      found = true
      break
    end
  end

  f.close

  if found
    res.body = 'Login successful'
  else
    res.body = 'Password is incorrect'
  end
end

trap("INT"){ srv.shutdown }

srv.start
