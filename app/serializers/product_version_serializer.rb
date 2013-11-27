class ProductVersionSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :name, :description, :image_url, :price
  attributes :price_shipping, :price_strikeout, :shipping_info, :available
  attributes :cashfront_value, :availability_info, :rating
  attributes :option1, :option2, :option3, :option4
  attributes :option1_md5, :option2_md5, :option3_md5, :option4_md5
  attributes :images
  
  def available
    object.available? ? 1 : 0
  end

  def rating
    object.rating.to_f.round(2)
  end

  def cashfront_value
    object.cashfront_value object.price, scope ? { developer:scope[:developer], device:scope[:device] } : nil
  end

  def option1
    JSON.parse(object.option1) unless object.option1.nil?
  end

  def option2
    JSON.parse(object.option2) unless object.option2.nil?
  end

  def option3
    JSON.parse(object.option3) unless object.option3.nil?
  end

  def option4
    JSON.parse(object.option4) unless object.option4.nil?
  end

  def images
    object.product_images.map { |i| {url:i.url, size:i.size} }
  end

  def include_description?
    scope.nil? || !scope[:short]
  end

  def include_images?
    scope.nil? || !scope[:short]
  end
end