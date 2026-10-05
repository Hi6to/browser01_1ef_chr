# coding: utf-8
require 'sqlite3'

# データベースに接続
db = SQLite3::Database.new("lab.db")

# メンバー名を入力
member_name = gets.chomp

# 入力されたメンバーが所属する研究室を検索し、
# 同じ研究室に所属する他のメンバーを取得する
sql = <<-SQL
  SELECT other.member_name
  FROM lab_members AS target
  INNER JOIN lab_members AS other
  ON target.lab_id = other.lab_id
  WHERE target.member_name = ?
  AND other.member_name != ?
SQL

# プレースホルダを使用して検索
db.execute(sql, [member_name, member_name]) do |row|
  puts row[0]
end

# データベースを閉じる
db.close