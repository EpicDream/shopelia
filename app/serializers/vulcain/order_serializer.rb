class Vulcain::OrderSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :vendor, :context
  
  def vendor
    object.merchant.vendor
  end
  
  def context
    Vulcain::ContextSerializer.new(object).as_json[:context]
  end

end
