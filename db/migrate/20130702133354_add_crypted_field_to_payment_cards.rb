class AddCryptedFieldToPaymentCards < ActiveRecord::Migration
  def up
    add_column :payment_cards, :crypted, :text
    PaymentCard.all.each do |card|
      card.save!
    end
    remove_column :payment_cards, :number
    remove_column :payment_cards, :exp_month
    remove_column :payment_cards, :exp_year
    remove_column :payment_cards, :cvv
  end

  def down
    remove_column :payment_cards, :crypted
  end
end
