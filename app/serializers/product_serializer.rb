class ProductSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :image_url, :name, :url, :merchant
end
