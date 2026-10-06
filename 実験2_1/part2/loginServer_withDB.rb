# coding: utf-8
# loginServer_withDB.rb
# 応用課題3-3: users.db に登録されたユーザ名とパスワードでログイン判定を行う Web サーバ
#   /form  : ログイン用のフォーム（login.html）を返す
#   /login : user と password を受け取り，データベースの内容と比較する
require 'webrick'
require 'sqlite3'
require 'cgi'

DB_FILE = 'users.db' # 事前に作成しておくユーザ管理用データベース

# リクエストのパラメータを UTF-8 の文字列として取り出す（未指定なら空文字）
def param(req, key)
  req.query[key].to_s.dup.force_encoding('UTF-8')
end

# DocumentRoot を指定しないことで，users.db をブラウザから取得できないようにする
srv = WEBrick::HTTPServer.new({
  :BindAddress => '127.0.0.1',
  :Port => 2000
})

# /form で入力フォームを返す
# フォームの action="login" は相対パスなので，送信先は /login になる
srv.mount('/form', WEBrick::HTTPServlet::FileHandler, 'login.html')

# /login : フォームから POST された user と password を判定する
# （req.query は POST のフォームデータも GET の URL パラメータも取得できる）
srv.mount_proc('/login') do |req, res|
  user = param(req, 'user')
  password = param(req, 'password')

  db = SQLite3::Database.new(DB_FILE)
  # ユーザ名とパスワードの両方が一致する行の数を数える
  # プレースホルダ ? を使うことで，' OR '1'='1 のような入力でも SQL 文の構造は変わらない
  count = db.get_first_value(
    'SELECT COUNT(*) FROM users WHERE user_name = ? AND password = ?',
    [user, password]
  )
  db.close

  res['Content-Type'] = 'text/html; charset=UTF-8'
  if count > 0
    # ユーザ名を HTML に埋め込むので，XSS 対策としてエスケープする
    res.body = "<html><body><h1>Login successful</h1><p>Welcome, #{CGI.escapeHTML(user)}!</p></body></html>"
  else
    # ユーザ名が無い場合とパスワードが違う場合を区別しない（どちらが誤りか攻撃者に教えないため）
    res.body = "<html><body><h1>Login failed</h1><p>User name or password is incorrect.</p><p><a href=\"/form\">Back</a></p></body></html>"
  end
end

trap("INT"){ srv.shutdown } # Ctrl+C でサーバを停止

srv.start
