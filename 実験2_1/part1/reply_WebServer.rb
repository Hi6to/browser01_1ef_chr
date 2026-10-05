# coding: utf-8
require 'webrick'

srv = WEBrick::HTTPServer.new({
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 2000
})

srv.mount_proc('/time') do |req, res|
  res['Content-Type'] = 'text/html; charset=UTF-8'
  res.body = "<html><body><h1>現在時刻</h1><p>#{Time.now}</p></body></html>"
end

srv.mount_proc('/fizzbuzz') do |req, res|
  num = req.query['num'].to_i

  html = "<html><body>"
  html += "<h1>FizzBuzz</h1>"
  html += "<table border='1'>"
  html += "<tr><th>数値</th><th>結果</th></tr>"

  1.upto(num) do |i|
    if i % 15 == 0
      result = 'Fizz Buzz'
    elsif i % 3 == 0
      result = 'Fizz'
    elsif i % 5 == 0
      result = 'Buzz'
    else
      result = i.to_s
    end

    html += "<tr><td>#{i}</td><td>#{result}</td></tr>"
  end

  html += "</table>"
  html += "</body></html>"

  res['Content-Type'] = 'text/html; charset=UTF-8'
  res.body = html
end

trap("INT"){ srv.shutdown }

srv.start
