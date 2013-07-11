class AddMangopayAmazonVoucherToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :mangopay_amazon_voucher_id, :integer
    add_column :orders, :mangopay_amazon_voucher_code, :string
  end
end
