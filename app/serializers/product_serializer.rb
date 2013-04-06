class ProductSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :image_url, :name, :url, :merchant

  def merchant
    MerchantSerializer.new(object.merchant).as_json[:merchant]
  end
end
