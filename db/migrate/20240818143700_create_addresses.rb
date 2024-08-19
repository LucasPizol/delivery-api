class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :city, null: false
      t.string :number, null: false
      t.string :complement
      t.string :street, null: false
      t.string :zip_code, null: false
      t.string :state, null: false

      t.belongs_to :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
