class ProductVersionSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :name, :description, :images, :size, :color, :price
  attributes :price_shipping, :price_strikeout, :shipping_info, :available
  
  def available
    object.available? ? 1 : 0
  end
end
