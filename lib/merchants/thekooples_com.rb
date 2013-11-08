# -*- encoding : utf-8 -*-
class ThekooplesCom
  DEFAULT_PRICE_SHIPPING = "0.00 €"
  DEFAULT_SHIPPING_INFO = "The Kooples expédie ses colis avec la solution express TNT en 48 h."

  AVAILABILITY_HASH = {
    "ooops" => false,
  }

  def initialize url
    @url = url
  end

  def process_availability version
    version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end

end