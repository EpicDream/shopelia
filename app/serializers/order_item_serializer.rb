class OrderItemSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :url, :quantity, :price, :product_version_id, :options
  
  def id
    object.product.id
  end

  def product_version_id
    object.product_version_id
  end

  def url
    Linker.monetize(object.product.url)
  end

  def options
    [ object.product_version.option1.nil? ? nil : JSON.parse(object.product_version.option1),
      object.product_version.option2.nil? ? nil : JSON.parse(object.product_version.option2),
      object.product_version.option3.nil? ? nil : JSON.parse(object.product_version.option3),
      object.product_version.option4.nil? ? nil : JSON.parse(object.product_version.option4) ].delete_if{|e| e.nil?}
  end
end
