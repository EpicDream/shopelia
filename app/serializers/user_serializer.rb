class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :addresses, :payment_cards, :has_pincode, :has_password
  
  def payment_cards
    ActiveModel::ArraySerializer.new(object.payment_cards).as_json
  end

  def addresses
    ActiveModel::ArraySerializer.new(object.addresses).as_json
  end
  
  def has_pincode
    object.has_pincode? ? 1 : 0
  end

  def has_password
    object.has_password? ? 1 : 0
  end
end
