class OrderSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :uuid, :state, :products, :merchant, :message, :questions
  attributes :expected_price_product, :expected_price_shipping, :expected_price_total
  attributes :prepared_price_product, :prepared_price_shipping, :prepared_price_total
  attributes :billed_price_product, :billed_price_shipping, :billed_price_total
  attributes :shipping_information
  
  def state
    object.state_name
  end
  
  def products
    ActiveModel::ArraySerializer.new(object.order_items).as_json
  end

  def merchant
    MerchantSerializer.new(object.merchant).as_json[:merchant]
  end
    
  def include_questions?
    object.state == :pending_answer
  end
  
  def include_payment_card?
    object.payment_card.present?
  end

end
