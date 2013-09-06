class ProductVersionSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :name, :description, :image_url, :size, :color, :price
  attributes :price_shipping, :price_strikeout, :shipping_info, :available
  attributes :cashfront_value, :availability_info
  
  def available
    object.available? ? 1 : 0
  end

  def cashfront_value
    object.cashfront_value object.price, scope ? { developer:scope[:developer] } : nil
  end
end
