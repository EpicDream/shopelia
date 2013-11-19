class Viking::MerchantSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  attributes :id, :data, :mapping_id
  
  def data
    object.viking_data.nil? ? nil : JSON.parse(object.viking_data)
  end
end
