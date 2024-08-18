class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false
      t.text :description
      t.float :price, null: false
      t.string :category, null: false

      t.string :picture_url
      t.belongs_to :company, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
