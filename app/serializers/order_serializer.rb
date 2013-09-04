class OrderSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :uuid, :state, :products, :merchant, :message, :questions
  attributes :expected_price_product, :expected_price_shipping, :expected_price_total
  attributes :prepared_price_product, :prepared_price_shipping, :prepared_price_total
  attributes :billed_price_product, :billed_price_shipping, :billed_price_total
  attributes :shipping_info, :address, :payment_card
  
  def state
    object.state_name
  end
  
  def products
    ActiveModel::ArraySerializer.new(object.order_items).as_json
  end

  def merchant
    MerchantSerializer.new(object.merchant).as_json[:merchant]
  end

  def address
    AddressSerializer.new(object.meta_order.address).as_json[:address]
  end

  def payment_card
    PaymentCardSerializer.new(object.meta_order.payment_card).as_json[:payment_card]
  end
    
  def include_questions?
    object.state == :pending_answer
  end

end
