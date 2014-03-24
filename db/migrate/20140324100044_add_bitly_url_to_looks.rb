class AddBitlyUrlToLooks < ActiveRecord::Migration
  def change
    add_column :looks, :bitly_url, :string
  end
end