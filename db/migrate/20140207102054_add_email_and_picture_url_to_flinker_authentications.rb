class AddEmailAndPictureUrlToFlinkerAuthentications < ActiveRecord::Migration
  def change
    add_column :flinker_authentications, :email, :string
    add_column :flinker_authentications, :picture, :text
  end
end