class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :username,null: false 
      t.string :email,null: false 
      t.string :name,null: false 
      t.string :role,null: false 
      t.string :password_digest,null: false 
      t.string :cpf,null: false 
      t.string :phone,null: false 
      t.belongs_to :company, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
