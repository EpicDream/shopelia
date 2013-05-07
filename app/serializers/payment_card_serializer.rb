class PaymentCardSerializer < ActiveModel::Serializer
  attributes :id, :number, :name, :exp_month, :exp_year
  
  def number
    object.number[0..1] + "XXXXXXXXXX" + object.number[12..15]
  end
end
