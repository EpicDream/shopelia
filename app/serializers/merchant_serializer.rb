class MerchantSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo, :url, :tc_url, :accepting_orders, :domain, :allow_quantities, :saturn
  
  def accepting_orders
    object.accepting_orders? ? 1 : 0
  end

  def allow_quantities
    object.allow_quantities? ? 1 : 0
  end

  def saturn
    object.viking_data.present? ? 1 : 0
  end
end
