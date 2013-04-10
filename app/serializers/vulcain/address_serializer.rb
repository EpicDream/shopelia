class Vulcain::AddressSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys

  attributes :address_1, :address_2, :zip, :city, :country, :additional_address
  
  def address_1
    object.address1
  end

  def address_2
    object.address2
  end
  
  def additional_address
    object.access_info
  end
  
  def country
    object.country.iso
  end
  
end
