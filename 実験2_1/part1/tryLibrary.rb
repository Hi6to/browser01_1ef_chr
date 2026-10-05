require "date"

today = Date.today
puts "今日の日付: #{today}"
puts "曜日: #{today.strftime("%A")}"

tomorrow = today + 1
puts "明日の日付: #{tomorrow}"

next_week = today + 7
puts "1週間後の日付: #{next_week}"

birthday = Date.new(2027, 1, 1)
days = birthday - today
puts "2027年1月1日までの日数: #{days.to_i}日"
