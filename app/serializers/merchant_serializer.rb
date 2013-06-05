class MerchantSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo, :url, :accepting_orders
  
  def accepting_orders
    object.accepting_orders? ? 1 : 0
  end
  
end
