require_relative '../models/product'
require 'sinatra/activerecord'

puts "Seeding data..."

if Product.count == 0
  Product.create(product_name: 'Product #1', amount_fractional: 10000, quantity: 2)
  Product.create(product_name: 'Product #2', amount_fractional: 11000, quantity: 1)
  Product.create(product_name: 'Product #3', amount_fractional: 12000, quantity: 5)
  Product.create(product_name: 'Product #4', amount_fractional: 13000, quantity: 3)
  Product.create(product_name: 'Product #5', amount_fractional: 14000, quantity: 4)
end

puts "Seeding completed! rake db:seed"
