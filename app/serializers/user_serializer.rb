class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :auth_token, :phones, :addresses
  
  def auth_token
    object.authentication_token
  end

  def addresses
    object.addresses ? ActiveModel::ArraySerializer.new(object.addresses).as_json : nil
  end
  
  def phones
    object.phones ? ActiveModel::ArraySerializer.new(object.phones).as_json : nil
  end
end
