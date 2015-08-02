class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :friend_id
      t.boolean :approved, default: false

      t.timestamps null: false
    end
    add_index :friendships, :friend_id
  end
end
