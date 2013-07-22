class Viking::MerchantSerializer < ActiveModel::Serializer
  attributes :id, :data
  
  def data
    JSON.parse(object.viking_data)
  end
end
