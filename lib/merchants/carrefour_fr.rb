# -*- encoding : utf-8 -*-
class CarrefourFr
  DEFAULT_PRICE_SHIPPING = MerchantHelper::FREE_PRICE
  DEFAULT_SHIPPING_INFO = "A la remise de votre colis au transporteur, livraison en 2 à 4 jours du lundi au samedi directement chez vous."

  AVAILABILITY_HASH = {
    "\d+ produit" => false # search-result
  }

  def initialize url
    @url = url
  end

  def canonize
    @url
  end

  def process_availability version
    version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_price_shipping version
    if version[:price_shipping_text].blank?
      version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
    elsif version[:price_shipping_text] =~ /LIVRAISON INCLUSE/i
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE
    end
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version[:shipping_info].sub!(/D.lais et tarifs de livraison pour ce produit/i, '')
    version[:shipping_info].sub!("En savoir plus sur la livraison", '')
    version
  end
end