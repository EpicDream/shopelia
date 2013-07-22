class Viking::MerchantSerializer < ActiveModel::Serializer
  attributes :id, :data
  
  def data
    object.viking_data
  end
end
