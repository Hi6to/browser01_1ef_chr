# FizzBuzz.rb

num = gets.to_i

1.upto(num) do |i|
  if i % 15 == 0
    puts "Fizz Buzz"
  elsif i % 3 == 0
    puts "Fizz"
  elsif i % 5 == 0
    puts "Buzz"
  else
    puts i
  end
end
