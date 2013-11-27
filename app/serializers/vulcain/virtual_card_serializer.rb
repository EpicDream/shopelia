class Vulcain::VirtualCardSerializer < ActiveModel::Serializer
  attributes :holder, :number, :exp_month, :exp_year, :cvv
  
  def holder
    "Shopelia Virtualis"
  end
  
  def exp_month
    object.exp_month.gsub(/^0/, "")
  end
end
