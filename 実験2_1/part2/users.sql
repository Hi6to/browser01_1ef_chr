-- users.sql
-- 応用課題3-3 で使うユーザ管理用データベースの作成と初期データの登録
-- 使い方: sqlite3 users.db < users.sql

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  user_name TEXT UNIQUE NOT NULL, -- ユーザ名（重複不可）
  password TEXT NOT NULL
);

INSERT INTO users (user_name, password) VALUES ('yamada', 'hoge');
INSERT INTO users (user_name, password) VALUES ('tanaka', 'hirakegoma');
INSERT INTO users (user_name, password) VALUES ('sato', 'abc123');
