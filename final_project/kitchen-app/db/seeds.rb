require_relative '../models/dish'
require 'sinatra/activerecord'

puts "Seeding data..."

if Dish.count == 0
  Dish.create(dish_name: 'Dish #1', amount_fractional: 10000, quantity: 2)
  Dish.create(dish_name: 'Dish #2', amount_fractional: 11000, quantity: 1)
  Dish.create(dish_name: 'Dish #3', amount_fractional: 12000, quantity: 5)
  Dish.create(dish_name: 'Dish #4', amount_fractional: 13000, quantity: 3)
  Dish.create(dish_name: 'Dish #5', amount_fractional: 14000, quantity: 4)
end

puts "Seeding completed! rake db:seed"
