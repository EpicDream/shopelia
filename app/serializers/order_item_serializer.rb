class OrderItemSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :product, :quantity, :price_product, :price_delivery, :product_title, :product_image_url, :price_text, :delivery_text
  
  def product
    ProductSerializer.new(object.product).as_json[:product]
  end

end
