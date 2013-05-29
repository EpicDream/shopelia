class Vulcain::UserSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :birthdate, :gender, :address

  def birthdate
    { :day => object.birthdate.day, :month => object.birthdate.month, :year => object.birthdate.year }
  end
  
  def gender
    object.civility
  end
  
  def address
    Vulcain::AddressSerializer.new(Address.find(scope[:address_id])).as_json[:address]
  end
  
end
