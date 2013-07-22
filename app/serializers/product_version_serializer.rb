class ProductVersionSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :name, :description, :images, :size, :color, :price, :price_shipping, :price_strikeout, :shipping_info
end
