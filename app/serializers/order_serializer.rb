class OrderSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :uuid, :state, :product, :merchant, :message, :price_product, :price_delivery, :price_total
  
  def state
    object.state_name
  end
  
  def product
    ProductSerializer.new(object.product).as_json[:product]
  end

  def merchant
    MerchantSerializer.new(object.merchant).as_json[:merchant]
  end

end
