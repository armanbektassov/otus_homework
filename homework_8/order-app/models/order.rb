require 'sinatra/activerecord'

class Order < ActiveRecord::Base
  validates :user_id, presence: true
  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1, message: "must be at least 1" }
  validates :hour, presence: true, inclusion: { in: 9..17, message: "must be between 9 and 17" }
end