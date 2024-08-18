class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name,null: false 
      t.string :cnpj,null: false 
      t.string :street,null: false 
      t.string :neighborhood,null: false 
      t.string :city,null: false 
      t.string :state,null: false 
      t.text :description
      t.string :number,null: false
      t.string :complement

      t.belongs_to :user, foreign_key: true, type: :uuid, null: false

      t.timestamps
    end
  end
end
