class Vulcain::AddressSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys

  attributes :first_name, :last_name, :mobile_phone, :land_phone
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
  
  def zip
    object.zip.gsub(/[^\d]/, "")
  end

  def mobile_phone
    PhoneParser.is_mobile?(object.phone, object.country.iso) ? object.phone : nil
  end

  def land_phone
    PhoneParser.is_mobile?(object.phone, object.country.iso) ? nil : object.phone
  end
  
end
