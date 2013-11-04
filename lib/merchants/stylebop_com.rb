# -*- encoding : utf-8 -*-
class StylebopCom
  DEFAULT_PRICE_SHIPPING = "10.00 €"
  DEFAULT_SHIPPING_INFO = "Livraison UPS en 2-3 jours ouvrables (France)"

  AVAILABILITY_HASH = {
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
