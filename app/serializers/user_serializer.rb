class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :auth_token, :phones, :addresses
  
  def auth_token
    object.authentication_token
  end

  def addresses
    ActiveModel::ArraySerializer.new(object.addresses).as_json
  end
  
  def phones
    ActiveModel::ArraySerializer.new(object.phones.without_addresses).as_json
  end
end
