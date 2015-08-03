class RenameAccessTokenDigestToAccessTokenInUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :access_token_digest, :access_token
    end
  end
end
