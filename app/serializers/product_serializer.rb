class ProductSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :image_url, :name, :url, :merchant, :description, :master_id, :versions, :brand, :reference
 
  def master_id
    object.product_master_id
  end

  def merchant
    MerchantSerializer.new(object.merchant).as_json[:merchant]
  end
  
  def versions
    ActiveModel::ArraySerializer.new(object.product_versions.where(available:true)).as_json
  end
end
