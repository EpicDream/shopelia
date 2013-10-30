class ProductSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :id, :image_url, :name, :url, :merchant, :description, :master_id
  attributes :versions, :brand, :reference, :ready, :options_completed, :price
 
  def ready
    object.ready? ? 1 : 0
  end
 
  def options_completed
    object.options_completed? ? 1 : 0
  end

  def master_id
    object.product_master_id
  end

  def merchant
    MerchantSerializer.new(object.merchant).as_json[:merchant]
  end
  
  def versions
    ActiveModel::ArraySerializer.new(object.product_versions.available, scope:scope).as_json
  end

  def include_description?
    scope.nil? || !scope[:short]
  end

  def include_versions?
    scope.nil? || !scope[:short]
  end
end