# coding: utf-8
require 'webrick'
require 'sqlite3'

srv = WEBrick::HTTPServer.new(
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 2000
)

# Search members by lab name
srv.mount_proc('/lab_search') do |req, res|

  lab_name = req.query['lab_name']

  db = SQLite3::Database.new('lab.db')

  result = ""

  # Find lab_id from lab_name
  lab_id = nil

  db.execute("SELECT id, lab_name FROM labs") do |row|
    if row[1].to_s.strip == lab_name.to_s.strip
      lab_id = row[0]
      break
    end
  end

  if lab_id.nil?

    result = "Lab not found"

  else

    # Find members using lab_id
    db.execute(
      "SELECT member_name FROM lab_members WHERE lab_id = ?",
      [lab_id]
    ) do |row|

      result += row[0].to_s + "<br>"

    end

  end

  db.close

  res['Content-Type'] = 'text/html; charset=UTF-8'
  res.body = result
end


# Search other members by member name
srv.mount_proc('/member_search') do |req, res|

  member_name = req.query['member_name']

  db = SQLite3::Database.new('lab.db')

  result = ""

  # Find the lab_id of the specified member
  lab_id = nil

  db.execute("SELECT lab_id, member_name FROM lab_members") do |row|

    if row[1].to_s.strip == member_name.to_s.strip
      lab_id = row[0]
      break
    end

  end

  if lab_id.nil?

    result = "Member not found"

  else

    # Find other members in the same lab
    db.execute(
      "SELECT member_name FROM lab_members WHERE lab_id = ?",
      [lab_id]
    ) do |row|

      if row[0].to_s.strip != member_name.to_s.strip
        result += row[0].to_s + "<br>"
      end

    end

  end

  db.close

  res['Content-Type'] = 'text/html; charset=UTF-8'
  res.body = result
end

trap("INT") {
  srv.shutdown
}

srv.start

