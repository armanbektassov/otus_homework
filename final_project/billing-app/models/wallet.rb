require 'sinatra/activerecord'

class Wallet < ActiveRecord::Base
  validates :user_id, presence: true, uniqueness: true
  validates :amount_fractional, presence: true, length: { minimum: 0 }
end