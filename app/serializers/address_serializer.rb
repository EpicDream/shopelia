class AddressSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys

  attributes :id, :code_name, :address1, :address2, :zip, :city, :country
  attributes :access_info, :state, :is_default, :phone, :first_name, :last_name
  
  def is_default
    object.is_default? ? 1 : nil
  end
  
  def country
    object.country.iso
  end
  
  def state
    object.state ? object.state.name : nil
  end
  
end
