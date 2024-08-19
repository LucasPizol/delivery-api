class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.date :finished_at
      t.string :status, null: false
      t.string :observation

      t.belongs_to :company, null: false, foreign_key: true, type: :uuid
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid
      t.belongs_to :address, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
