class PaymentCardSerializer < ActiveModel::Serializer
  attributes :id, :number, :name, :exp_month, :exp_year
end
