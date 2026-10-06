# coding: utf-8
# bulletinBoard_Server_withDB.rb
# 応用課題3-2: ユーザ名とメッセージを SQLite のデータベースに保存する掲示板サーバ
#   /write?user=...&msg=... : 書き込みを保存し，発行した id を返す
#   /index                  : 保存されている書き込みの「ユーザ名, id」一覧を返す
#   /read?id=...            : 指定された id の「ユーザ名,メッセージ」を返す
require 'webrick'
require 'sqlite3'

DB_FILE = 'board.db' # 書き込みを保存するデータベースファイル

# 起動時に posts テーブルが無ければ作成する（既にあればそのまま使う）
# id は AUTOINCREMENT により自動で一意な値が振られる
db = SQLite3::Database.new(DB_FILE)
db.execute(<<-SQL)
  CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_name TEXT NOT NULL,
    message TEXT NOT NULL
  )
SQL
db.close

# 禁止ワード（応用課題2-1 から引き継いだ追加機能）
banned_words = ['die', 'kill', 'stupid']

# リクエストのパラメータを UTF-8 の文字列として取り出す
# （WEBrick のパラメータはバイナリ扱いの文字列なので，そのまま保存すると BLOB になってしまう）
def param(req, key)
  value = req.query[key]
  return nil if value.nil?
  value.to_s.dup.force_encoding('UTF-8')
end

# DocumentRoot を指定しないことで，board.db などのファイルをブラウザから取得できないようにする
srv = WEBrick::HTTPServer.new({
  :BindAddress => '127.0.0.1',
  :Port => 2000
})

# Write
srv.mount_proc('/write') do |req, res|
  res['Content-Type'] = 'text/plain; charset=UTF-8'
  user = param(req, 'user')
  msg = param(req, 'msg')

  if user.nil? || user == '' || msg.nil? || msg == ''
    # user または msg が無い，あるいは空の場合
    res.body = 'Please enter user and message'
  elsif banned_words.any? { |word| msg.include?(word) }
    # 禁止ワードを含む場合は保存しない
    res.body = 'Your message contains a banned word'
  else
    db = SQLite3::Database.new(DB_FILE)
    # プレースホルダ ? を使い，入力値を SQL 文に直接埋め込まない（SQL インジェクション対策）
    db.execute('INSERT INTO posts (user_name, message) VALUES (?, ?)', [user, msg])
    id = db.last_insert_row_id # 今 INSERT した行に振られた id を取得
    db.close
    res.body = 'id:' + id.to_s
  end
end

# Index
srv.mount_proc('/index') do |req, res|
  res['Content-Type'] = 'text/plain; charset=UTF-8'
  result = ''

  db = SQLite3::Database.new(DB_FILE)
  db.execute('SELECT user_name, id FROM posts ORDER BY id') do |row|
    result += row[0] + ', ' + row[1].to_s + "\n" # 「ユーザ名, id」の形式
  end
  db.close

  if result == ''
    result = 'No messages' # 書き込みが1件も無い場合
  end

  res.body = result
end

# Read
srv.mount_proc('/read') do |req, res|
  res['Content-Type'] = 'text/plain; charset=UTF-8'
  id = req.query['id'].to_i

  db = SQLite3::Database.new(DB_FILE)
  # 該当する行が無い場合は nil が返る
  row = db.get_first_row('SELECT user_name, message FROM posts WHERE id = ?', [id])
  db.close

  if row.nil?
    res.body = 'Message not found'
  else
    res.body = row[0] + ',' + row[1] # 「ユーザ名,メッセージ」の形式
  end
end

trap("INT"){ srv.shutdown } # Ctrl+C でサーバを停止

srv.start
