class AddCryptedFieldToPaymentCards < ActiveRecord::Migration
  def up
    add_column :payment_cards, :crypted, :text
    PaymentCard.all.each do |card|
      card.save!
    end
  end

  def down
    remove_column :payment_cards, :crypted
  end
end
