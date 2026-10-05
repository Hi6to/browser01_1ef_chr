# coding: utf-8
require 'sqlite3'

# データベースに接続
db = SQLite3::Database.new("lab.db")

# 研究室名を入力
lab_name = gets.chomp

# 研究室名から、その研究室に所属するメンバーを検索
sql = <<-SQL
  SELECT lab_members.member_name
  FROM labs
  INNER JOIN lab_members
  ON labs.id = lab_members.lab_id
  WHERE labs.lab_name = ?
SQL

# プレースホルダを使用して検索
db.execute(sql, [lab_name]) do |row|
  puts row[0]
end

# データベースを閉じる
db.close