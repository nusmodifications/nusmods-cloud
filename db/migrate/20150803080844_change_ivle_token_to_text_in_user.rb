class ChangeIvleTokenToTextInUser < ActiveRecord::Migration
  def up
    change_column :users, :ivle_token, :text
  end

  def down
    change_column :users, :ivle_token, :string
  end
end
