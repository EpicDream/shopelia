class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :auth_token
  
  def auth_token
    object.authentication_token
  end
end
