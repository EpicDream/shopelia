class PaymentCardSerializer < ActiveModel::Serializer
  attributes :id, :number, :name, :exp_month, :exp_year
  
  def number
    object.number[0..3] + "XXXXXXXXXX" + object.number[14..15]
  end
end
