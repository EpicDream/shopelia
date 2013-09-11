class OrderItemSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :url, :quantity, :price, :product_version_id
  attributes :option1, :option2, :option3, :option4
  
  def id
    object.product.id
  end

  def product_version_id
    object.product_version_id
  end

  def url
    Linker.monetize(object.product.url)
  end

  def option1
    object.product_version.option1.nil? ? nil : JSON.parse(object.product_version.option1)
  end

  def option2
    object.product_version.option2.nil? ? nil : JSON.parse(object.product_version.option2)
  end

  def option3
    object.product_version.option3.nil? ? nil : JSON.parse(object.product_version.option3)
  end

  def option4
    object.product_version.option4.nil? ? nil : JSON.parse(object.product_version.option4)
  end
end
