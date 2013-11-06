# -*- encoding : utf-8 -*-
class PixmaniaFr
  DEFAULT_PRICE_SHIPPING = "5,99 €"
  DEFAULT_SHIPPING_INFO = "Colis Privé vous livre en 4 à 6 jours ouvrés du lundi au vendredi de 8h à 18h."

  AVAILABILITY_HASH = {
  }

  def initialize url
    @url = url
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