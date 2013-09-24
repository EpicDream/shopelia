class Viking::ProductSerializer < ActiveModel::Serializer
  attributes :id, :url, :merchant_id, :batch
end