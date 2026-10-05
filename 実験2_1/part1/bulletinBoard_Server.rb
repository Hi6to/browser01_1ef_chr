# coding: utf-8
require 'webrick'

srv = WEBrick::HTTPServer.new({
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 2000
})

# Save messages
messages = []

# Banned words
banned_words = ['die', 'kill', 'stupid']

# Write
srv.mount_proc('/write') do |req, res|
  msg = req.query['msg']

  if msg.nil? || msg == ''
    res.body = 'Please enter a message'
  else

    found = false

    banned_words.each do |word|
      if msg.include?(word)
        found = true
        break
      end
    end

    if found
      res.body = 'Your message contains a banned word'
    else
      id = messages.length + 1

      messages << [id, msg]

      res.body = 'id:' + id.to_s
    end
  end
end

# Index
srv.mount_proc('/index') do |req, res|
  result = ''

  messages.each do |message|
    result += 'id:' + message[0].to_s + "\n"
  end

  if result == ''
    result = 'No messages'
  end

  res.body = result
end

# Read
srv.mount_proc('/read') do |req, res|
  id = req.query['id'].to_i

  found = false

  messages.each do |message|
    if message[0] == id
      res.body = message[1]
      found = true
      break
    end
  end

  if found == false
    res.body = 'Message not found'
  end
end

trap("INT"){ srv.shutdown }

srv.start
