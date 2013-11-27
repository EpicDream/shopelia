class CardIdStringVirtualCards < ActiveRecord::Migration
  def up
    change_column :virtual_cards, :cvd_id, :string
  end

  def down
    change_column :virtual_cards, :cvd_id, :integer
  end
end
