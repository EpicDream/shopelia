class OrderSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :uuid, :state, :products, :merchant, :message, :price_product, :price_delivery, :price_total
  
  def state
    object.state_name
  end
  
  def products
    ActiveModel::ArraySerializer.new(object.order_items).as_json
  end

  def merchant
    MerchantSerializer.new(object.merchant).as_json[:merchant]
  end

end
