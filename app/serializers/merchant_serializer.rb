class MerchantSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo, :url, :accepting_orders, :domain, :allow_quantities
  
  def accepting_orders
    object.accepting_orders? ? 1 : 0
  end

  def allow_quantities
    object.allow_quantities? ? 1 : 0
  end  
end
