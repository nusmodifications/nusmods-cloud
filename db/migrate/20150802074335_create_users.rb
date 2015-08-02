class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nusnet_id, null: false
      t.string :name
      t.string :email
      t.string :gender
      t.string :faculty
      t.string :first_major
      t.string :second_major
      t.integer :matriculation_year
      t.string :ivle_token
      t.string :access_token_digest

      t.timestamps null: false
    end
    add_index :users, :nusnet_id, unique: true
  end
end
