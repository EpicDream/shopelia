class AddressSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys

  attributes :id, :code_name, :address1, :address2, :zip, :city, :country, :access_info, :state, :is_default, :phones
  
  def is_default
    object.is_default? ? 1 : nil
  end
  
  def country
    object.country.iso
  end
  
  def state
    object.state ? object.state.name : nil
  end
  
  def phones
    object.phones ? ActiveModel::ArraySerializer.new(object.phones).as_json : nil
  end
  
end
