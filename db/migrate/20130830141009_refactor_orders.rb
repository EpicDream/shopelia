class RefactorOrders < ActiveRecord::Migration
  def up
    add_column :meta_orders, :address_id, :integer
    add_column :meta_orders, :payment_card_id, :integer
    add_column :meta_orders, :mangopay_wallet_id, :integer
    add_column :meta_orders, :billing_solution, :string
    Order.all.each do |order|
      order.save # generate meta_order
      meta = order.meta_order
      meta.address_id = order.address_id
      meta.payment_card_id = order.payment_card_id
      meta.billing_solution = order.billing_solution
      if order.mangopay_wallet_id.present?
        meta.mangopay_wallet_id = order.mangopay_wallet_id
        BillingTransaction.create!(
          meta_order_id:meta.id,
          user_id:order.user_id,
          processor:'mangopay',
          amount:order.mangopay_contribution_amount,
          success:order.mangopay_contribution_status.eql?("success"),
          mangopay_contribution_id:order.mangopay_contribution_id,
          mangopay_contribution_amount:order.mangopay_contribution_amount,
          mangopay_contribution_message:order.mangopay_contribution_message,
          mangopay_destination_wallet_id:order.mangopay_wallet_id
        )
        PaymentTransaction.create!(
          order_id:order.id,
          processor:'amazon',
          mangopay_amazon_voucher_id:order.mangopay_amazon_voucher_id,
          mangopay_amazon_voucher_code:order.mangopay_amazon_voucher_code
        )
      end
      meta.save!
    end
    remove_column :orders, :address_id
    remove_column :orders, :payment_card_id
    remove_column :orders, :mangopay_wallet_id
    remove_column :orders, :mangopay_contribution_id
    remove_column :orders, :mangopay_contribution_amount
    remove_column :orders, :mangopay_contribution_status
    remove_column :orders, :mangopay_contribution_message
    remove_column :orders, :mangopay_amazon_voucher_id
    remove_column :orders, :mangopay_amazon_voucher_code
    remove_column :orders, :billing_solution
  end

  def down
  end
end
