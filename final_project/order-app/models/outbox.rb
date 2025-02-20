require 'sinatra/activerecord'

class Outbox < ActiveRecord::Base
  self.table_name = 'outbox'
end