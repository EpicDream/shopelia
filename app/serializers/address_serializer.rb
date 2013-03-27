class AddressSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys

  attributes :id, :code_name, :address1, :address2, :zip, :city, :country, :state, :is_default, :phones
  
  def is_default
    object.is_default? ? 1 : nil
  end
  
  def country
    object.country.name
  end
  
  def state
    object.state ? object.state.name : nil
  end
  
end
