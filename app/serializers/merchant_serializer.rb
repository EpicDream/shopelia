class MerchantSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo, :url, :accepting_orders, :allow_iframe, :domain
  
  def accepting_orders
    object.accepting_orders? ? 1 : 0
  end

  def allow_iframe
    object.allow_iframe? ? 1 : 0
  end
  
end
