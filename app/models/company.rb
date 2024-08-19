class Company < ApplicationRecord
  has_many :products
  has_many :orders
end
