class CreateOrderProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :order_products, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.float :quantity
      t.float :unit_price

      t.belongs_to :order, null: false, foreign_key: true, type: :uuid
      t.belongs_to :product, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
