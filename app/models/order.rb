class Order < ApplicationRecord
  belongs_to :user
  has_many :order_products
  belongs_to :company
  belongs_to :address
end
