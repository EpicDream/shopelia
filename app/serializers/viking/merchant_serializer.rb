class Viking::MerchantSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  attributes :id, :mapping_id
end
