require 'webrick'
srv = WEBrick::HTTPServer.new({ :DocumentRoot => './',
    :BindAddress => '127.0.0.1',
    :Port => 2000})
srv.mount('/hoge', WEBrick::HTTPServlet::FileHandler, 'hoge.txt')
trap("INT"){ srv.shutdown }
srv.start 