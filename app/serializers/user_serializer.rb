class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :phones, :addresses, :payment_cards
  
  def payment_cards
    ActiveModel::ArraySerializer.new(object.payment_cards).as_json
  end

  def addresses
    ActiveModel::ArraySerializer.new(object.addresses).as_json
  end
  
  def phones
    ActiveModel::ArraySerializer.new(object.phones.without_addresses).as_json
  end
end
