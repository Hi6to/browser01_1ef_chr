require 'webrick'
srv = WEBrick::HTTPServer.new({ :DocumentRoot => './',
    :BindAddress => '127.0.0.1',
    :Port => 2000})
srv.mount('/test', WEBrick::HTTPServlet::FileHandler, 'test.html')
trap("INT"){ srv.shutdown }
srv.start