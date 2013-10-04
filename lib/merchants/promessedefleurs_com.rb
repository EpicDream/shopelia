# -*- encoding : utf-8 -*-
class PromessedefleursCom

  def initialize url
    @url = url
  end

  def process_shipping_price version
    version[:price_shipping_text] = "6,90 € (à titre indicatif)"
    version
  end
end