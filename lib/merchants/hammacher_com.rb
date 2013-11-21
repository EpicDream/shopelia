# -*- encoding : utf-8 -*-
class HammacherCom

  def initialize url
    @url = url
  end

  def process_shipping_price version
    version[:price_shipping_text] = "75,95 $ (à titre indicatif)"
    version
  end
end