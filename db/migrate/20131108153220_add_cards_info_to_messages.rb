class AddCardsInfoToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :collection_uuid, :string
    add_column :messages, :gift_gender, :string
    add_column :messages, :gift_age, :string
    add_column :messages, :gift_budget, :string
  end
end
