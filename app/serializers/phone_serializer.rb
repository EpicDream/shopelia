class PhoneSerializer < ActiveModel::Serializer
  attributes :id, :number, :line_type, :address_id
  
  def include_address_id?
    !scope || scope[:address_context].nil?
  end
end
