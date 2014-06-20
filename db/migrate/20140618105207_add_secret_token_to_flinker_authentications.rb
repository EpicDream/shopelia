class AddSecretTokenToFlinkerAuthentications < ActiveRecord::Migration
  def change
    add_column :flinker_authentications, :token_secret, :string
  end
end