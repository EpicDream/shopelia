class ProductSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :image_url, :name, :url, :merchant, :description, :master_id, :versions, :brand, :reference, :ready
 
  def ready
    !object.viking_failure && object.versions_expires_at.present? && object.versions_expires_at > Time.now ? 1 : 0
  end
 
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
