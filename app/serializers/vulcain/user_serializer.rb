class Vulcain::UserSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys
  
  attributes :birthdate, :gender, :address

  def birthdate
    if object.birthdate.nil?
      { :day => 1, :month => 1, :year => 1980 }
    else
      { :day => object.birthdate.day, :month => object.birthdate.month, :year => object.birthdate.year }
    end
  end
  
  def gender
    object.civility.nil? ? User::CIVILITY_MR : object.civility
  end
  
  def address
    Vulcain::AddressSerializer.new(Address.find(scope[:address_id])).as_json[:address]
  end
  
end
