require "cgi"
cgi = CGI.new

cgi.out("type" => "text/html" ,"charset" => "UTF-8") do
# パラメータ取得
    msg = cgi["message"]
    iteration = cgi["iter"].to_i
    html = "<html><body>\n"
    iteration.times do |i|
    html = html + "<p>#{i}: #{msg}</p>"
    end
    html = html + "</body></html>"
    html
end