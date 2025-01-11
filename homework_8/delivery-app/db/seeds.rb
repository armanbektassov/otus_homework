require_relative '../models/hour'
require 'sinatra/activerecord'

puts "Seeding data..."

if Hour.count == 0
  Hour.create(hour: 9, busy: true)
  Hour.create(hour: 10, busy: false)
  Hour.create(hour: 11, busy: true)
  Hour.create(hour: 12, busy: true)
  Hour.create(hour: 13, busy: false)
  Hour.create(hour: 14, busy: true)
  Hour.create(hour: 15, busy: true)
  Hour.create(hour: 16, busy: false)
  Hour.create(hour: 17, busy: true)
end

puts "Seeding completed! rake db:seed"
