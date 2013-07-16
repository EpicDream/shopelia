class OrderItemSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :product, :quantity, :price
  
  def product
    ProductSerializer.new(object.product).as_json[:product]
  end

end
