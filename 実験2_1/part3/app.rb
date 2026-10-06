# coding: utf-8
# app.rb
# 基本課題4-1: 応用課題3-1 の研究室検索を Sinatra と ActiveRecord で実装したもの
#   /                              : 検索画面（index.erb）
#   /lab_search?lab_name=...       : 研究室名から所属メンバーの一覧を表示（lab_search.erb）
#   /member_search?member_name=... : メンバー名から同じ研究室の他のメンバーの一覧を表示（member_search.erb）
require 'logger'
require 'sinatra'
require 'sinatra/reloader'
require 'active_record'

# 実習書のリクエスト例に合わせて 127.0.0.1 の2000番ポートで起動する（デフォルトは4567番）
set :bind, '127.0.0.1'
set :port, 2000

# 基本課題3-3 で作成した lab.db に接続する
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'lab.db'
)

# labs テーブルに対応するモデル（クラス名 Lab から，テーブル名 labs が自動で決まる）
class Lab < ActiveRecord::Base
end

# lab_members テーブルに対応するモデル（クラス名 LabMember → テーブル名 lab_members）
class LabMember < ActiveRecord::Base
end

helpers do
  # ERB に値を埋め込むときに HTML エスケープする（XSS 対策）
  def h(text)
    Rack::Utils.escape_html(text.to_s)
  end
end

# 検索画面
get '/' do
  @title = 'Lab Search'
  @labs = Lab.all # 研究室名の一覧を検索画面に表示するために取得
  erb :index
end

# 研究室名から所属メンバーを検索
get '/lab_search' do
  @title = 'Lab Search Result'
  @lab_name = params[:lab_name].to_s

  # 研究室名が一致する研究室を1件取得（無ければ nil）
  # find_by や where は内部でプレースホルダを使うため，SQL インジェクションの心配がない
  @lab = Lab.find_by(lab_name: @lab_name)

  if @lab.nil?
    @members = [] # 該当する研究室が無い場合は空の一覧
  else
    # 研究室の id と lab_id が一致するメンバーを取得
    @members = LabMember.where(lab_id: @lab.id)
  end

  erb :lab_search
end

# メンバー名から同じ研究室の他のメンバーを検索
get '/member_search' do
  @title = 'Member Search Result'
  @member_name = params[:member_name].to_s

  # 入力されたメンバーを1件取得（無ければ nil）
  member = LabMember.find_by(member_name: @member_name)

  if member.nil?
    @lab = nil
    @members = []
  else
    # 所属研究室を取得
    @lab = Lab.find_by(id: member.lab_id)
    # 同じ lab_id を持つメンバーのうち，入力された本人（同じ id）以外を取得
    @members = LabMember.where(lab_id: member.lab_id).where.not(id: member.id)
  end

  erb :member_search
end
