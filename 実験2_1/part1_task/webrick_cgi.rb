require 'webrick'
CGI_PATH = '/usr/bin/ruby'
srv = WEBrick::HTTPServer.new({ :DocumentRoot => './',
    :BindAddress => '127.0.0.1',
    :Port => 2000,
    :CGIInterpreter => CGI_PATH})
srv.mount('/cgi', WEBrick::HTTPServlet::CGIHandler, 'cgi.rb')
trap("INT"){ srv.shutdown }
srv.start