class ProductVersionSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :name, :description, :image_url, :price
  attributes :price_shipping, :price_strikeout, :shipping_info, :available
  attributes :cashfront_value, :availability_info
  attributes :option1, :option2, :option3, :option4
  attributes :option1_md5, :option2_md5, :option3_md5, :option4_md5
  
  def available
    object.available? ? 1 : 0
  end

  def cashfront_value
    object.cashfront_value object.price, scope ? { developer:scope[:developer] } : nil
  end
end
