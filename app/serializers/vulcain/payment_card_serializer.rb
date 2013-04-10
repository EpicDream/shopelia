class Vulcain::PaymentCardSerializer < ActiveModel::Serializer
  attributes :holder, :number, :exp_month, :exp_year, :cvv
  
  def holder
    "#{object.user.first_name} #{object.user.last_name}"
  end
  
  def exp_month
    object.exp_month.gsub(/^0/, "")
  end
end
