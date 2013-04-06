class PhoneSerializer < ActiveModel::Serializer
  attributes :id, :number, :line_type, :address_id
end
