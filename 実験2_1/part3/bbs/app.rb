# coding: utf-8
# app.rb（応用課題4-1）
# セッションを用いたログイン機能を持つ掲示板
#   GET  /        : ログイン・新規登録画面（index.erb）
#   POST /login   : ログイン
#   POST /signup  : ユーザ登録
#   GET  /board   : 掲示板（board.erb，ログイン時のみ）
#   POST /board   : 書き込み（ログイン時のみ）
#   POST /logout  : ログアウト
require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'active_record'
require 'openssl'
require 'securerandom'
require 'rack/session/pool' # サーバ側にセッションを保存する Rack::Session::Pool

# セッションをサーバ側（メモリ上）に保存する
# ブラウザのクッキーにはセッション ID だけが保存され，ユーザ ID などの中身はクライアントに渡らない
use Rack::Session::Pool, expire_after: 60 * 60 # 1時間操作が無ければセッションを破棄

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'bbs.db'
)

# 起動時にテーブルが無ければ作成する（既にあればそのまま使う）
ActiveRecord::Schema.define do
  # ユーザ（パスワードはソルト付きでハッシュ化した値のみを保存する）
  create_table :users, if_not_exists: true do |t|
    t.string :name, null: false
    t.string :password_hash, null: false
    t.string :salt, null: false
  end
  add_index :users, :name, unique: true, if_not_exists: true # 同じユーザ名を登録できないようにする

  # 書き込み
  create_table :messages, if_not_exists: true do |t|
    t.integer :user_id, null: false # 書き込んだユーザ（users.id）
    t.text :content, null: false    # メッセージ本文
    t.timestamps                    # created_at（書き込み時刻）と updated_at を自動で記録
  end
end

# users テーブルに対応するモデル
class User < ActiveRecord::Base
  has_many :messages
end

# messages テーブルに対応するモデル（message.user で書き込んだユーザを取得できる）
class Message < ActiveRecord::Base
  belongs_to :user
end

# パスワードとソルトから PBKDF2 でハッシュ値を計算する
# 同じパスワードでもユーザごとにソルトが異なるため，ハッシュ値は異なる
def hash_password(password, salt)
  OpenSSL::KDF.pbkdf2_hmac(password, salt: salt, iterations: 10_000,
                           length: 32, hash: 'sha256').unpack1('H*')
end

helpers do
  # ERB に値を埋め込むときに HTML エスケープする（XSS 対策）
  def h(text)
    Rack::Utils.escape_html(text.to_s)
  end

  # ログイン中のユーザ（未ログインなら nil）
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # CSRF 対策用のトークン（セッションごとにランダムな値を1つ発行する）
  def csrf_token
    session[:csrf] ||= SecureRandom.hex(32)
  end

  # フォームに埋め込む CSRF トークンの hidden フィールド
  def csrf_tag
    "<input type=\"hidden\" name=\"csrf\" value=\"#{csrf_token}\">"
  end
end

# POST リクエストでは，フォームに埋め込んだ CSRF トークンがセッションのものと一致するか確認する
# 他のサイトから送らされたリクエストはトークンを知らないので拒否される
before do
  if request.post?
    valid = session[:csrf] && params[:csrf] &&
            Rack::Utils.secure_compare(params[:csrf].to_s, session[:csrf])
    halt 403, 'Invalid request' unless valid
  end
end

# ログイン画面
get '/' do
  redirect '/board' if current_user # ログイン済みなら掲示板へ
  erb :index
end

# ログイン
post '/login' do
  user = User.find_by(name: params[:name].to_s)

  # ユーザが存在し，入力されたパスワードのハッシュ値が保存されている値と一致すればログイン成功
  if user && Rack::Utils.secure_compare(hash_password(params[:password].to_s, user.salt), user.password_hash)
    env['rack.session.options'][:renew] = true # セッション ID を新しくする（セッション固定攻撃対策）
    session[:user_id] = user.id                # セッションにユーザ ID を保存してログイン状態にする
    redirect '/board'
  else
    @error = 'ログインできませんでした'
    erb :index # 元のログイン画面を表示
  end
end

# ユーザ登録
post '/signup' do
  name = params[:name].to_s.strip
  password = params[:password].to_s

  if name.empty? || password.empty?
    @error = 'ユーザ名とパスワードを入力してください'
  elsif User.exists?(name: name)
    @error = 'そのユーザ名は既に使われています'
  else
    salt = SecureRandom.hex(16) # ユーザごとにランダムなソルトを生成
    user = User.create!(name: name, salt: salt, password_hash: hash_password(password, salt))
    env['rack.session.options'][:renew] = true
    session[:user_id] = user.id # 登録後はそのままログイン状態にする
    redirect '/board'
  end

  erb :index # 登録できなかった場合はエラーを表示
end

# 掲示板
get '/board' do
  redirect '/' unless current_user # 未ログインならログイン画面へ
  # 全書き込みを古い順に取得（includes で書き込んだユーザもまとめて取得する）
  @messages = Message.includes(:user).order(:created_at)
  erb :board
end

# 書き込み
post '/board' do
  redirect '/' unless current_user
  text = params[:content].to_s.strip
  # ログイン中のユーザの書き込みとして保存（書き込み時刻は created_at に自動で記録される）
  Message.create!(user_id: current_user.id, content: text) unless text.empty?
  redirect '/board' # 再読み込みで二重投稿にならないよう，GET の掲示板にリダイレクトする
end

# ログアウト
post '/logout' do
  session.clear # セッションの中身を消去してログイン状態を解除
  redirect '/'
end
