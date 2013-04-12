class Vulcain::UserSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :first_name, :last_name, :birthdate, :gender, :mobile_phone, :land_phone, :address

  def birthdate
    { :day => object.birthdate.day, :month => object.birthdate.month, :year => object.birthdate.year }
  end
  
  def gender
    object.civility
  end
  
  def mobile_phone
    object.phones.mobile.first.try(:number)
  end
  
  def land_phone
    object.addresses.default.first.phones.first.try(:number)
  end
  
  def address
    Vulcain::AddressSerializer.new(object.addresses.default.first).as_json[:address]
  end
  
end
