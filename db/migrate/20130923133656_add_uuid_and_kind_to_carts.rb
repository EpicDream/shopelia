class AddUuidAndKindToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :uuid, :string
    add_column :carts, :kind, :integer
    Cart.update_all kind:Cart::FOLLOW
  end
end
