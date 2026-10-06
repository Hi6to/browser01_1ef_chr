# coding: utf-8
# app.rb（応用課題4-2）
# お気に入りの Web サイトを保存するアプリケーション（ログイン機能付き）
#   GET  /                    : ログイン・新規登録画面（index.erb）
#   POST /login               : ログイン
#   POST /signup              : ユーザ登録
#   GET  /weblist             : お気に入りの一覧と登録フォーム（weblist.erb，ログイン時のみ）
#   POST /weblist             : お気に入りの登録（ログイン時のみ）
#   POST /weblist/:id/delete  : お気に入りの削除（ログイン時のみ，追加機能）
#   POST /logout              : ログアウト
require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'active_record'
require 'openssl'
require 'securerandom'
require 'rack/session/pool' # サーバ側にセッションを保存する Rack::Session::Pool

# セッションをサーバ側（メモリ上）に保存する（クッキーにはセッション ID だけが入る）
use Rack::Session::Pool, expire_after: 60 * 60 # 1時間操作が無ければセッションを破棄

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'bookmark.db'
)

# 起動時にテーブルが無ければ作成する
ActiveRecord::Schema.define do
  # ユーザ（パスワードはソルト付きでハッシュ化した値のみを保存する）
  create_table :users, if_not_exists: true do |t|
    t.string :name, null: false
    t.string :password_hash, null: false
    t.string :salt, null: false
  end
  add_index :users, :name, unique: true, if_not_exists: true

  # お気に入りの Web サイト
  create_table :bookmarks, if_not_exists: true do |t|
    t.integer :user_id, null: false # 登録したユーザ（users.id）
    t.string :title, null: false    # ページ名
    t.string :url, null: false      # URL
    t.timestamps                    # created_at（登録日時）と updated_at
  end
end

# users テーブルに対応するモデル（user.bookmarks でそのユーザのお気に入りを取得できる）
class User < ActiveRecord::Base
  has_many :bookmarks
end

# bookmarks テーブルに対応するモデル
class Bookmark < ActiveRecord::Base
  belongs_to :user
end

# パスワードとソルトから PBKDF2 でハッシュ値を計算する
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

  # CSRF 対策用のトークン
  def csrf_token
    session[:csrf] ||= SecureRandom.hex(32)
  end

  # フォームに埋め込む CSRF トークンの hidden フィールド
  def csrf_tag
    "<input type=\"hidden\" name=\"csrf\" value=\"#{csrf_token}\">"
  end
end

# POST リクエストでは CSRF トークンを確認する
before do
  if request.post?
    valid = session[:csrf] && params[:csrf] &&
            Rack::Utils.secure_compare(params[:csrf].to_s, session[:csrf])
    halt 403, 'Invalid request' unless valid
  end
end

# ログイン画面
get '/' do
  redirect '/weblist' if current_user
  erb :index
end

# ログイン
post '/login' do
  user = User.find_by(name: params[:name].to_s)

  if user && Rack::Utils.secure_compare(hash_password(params[:password].to_s, user.salt), user.password_hash)
    env['rack.session.options'][:renew] = true # セッション ID を新しくする（セッション固定攻撃対策）
    session[:user_id] = user.id
    redirect '/weblist'
  else
    @error = 'ログインできませんでした'
    erb :index
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
    salt = SecureRandom.hex(16)
    user = User.create!(name: name, salt: salt, password_hash: hash_password(password, salt))
    env['rack.session.options'][:renew] = true
    session[:user_id] = user.id
    redirect '/weblist'
  end

  erb :index
end

# お気に入りの一覧
get '/weblist' do
  redirect '/' unless current_user
  # ログイン中のユーザが登録したものだけを，新しい順に取得する
  @bookmarks = current_user.bookmarks.order(created_at: :desc)
  erb :weblist
end

# お気に入りの登録
post '/weblist' do
  redirect '/' unless current_user
  title = params[:title].to_s.strip
  url = params[:url].to_s.strip

  if title.empty? || url.empty?
    @error = 'ページ名とURLを入力してください'
  elsif !url.match?(/\Ahttps?:\/\/\S+\z/)
    # javascript: などで始まる URL をリンクにすると XSS になるため，http(s) のみ受け付ける
    @error = 'URLは http:// または https:// で始まるものを入力してください'
  else
    current_user.bookmarks.create!(title: title, url: url)
    redirect '/weblist'
  end

  @bookmarks = current_user.bookmarks.order(created_at: :desc)
  erb :weblist # 登録できなかった場合はエラーを表示
end

# お気に入りの削除（追加機能）
post '/weblist/:id/delete' do
  redirect '/' unless current_user
  # current_user.bookmarks から探すことで，他のユーザのお気に入りは削除できないようにする
  bookmark = current_user.bookmarks.find_by(id: params[:id])
  bookmark.destroy if bookmark
  redirect '/weblist'
end

# ログアウト
post '/logout' do
  session.clear
  redirect '/'
end
