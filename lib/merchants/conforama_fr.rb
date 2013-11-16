# -*- encoding : utf-8 -*-
class ConforamaFr
  DEFAULT_PRICE_SHIPPING = "8 €"
  DEFAULT_SHIPPING_INFO = "Sous réserve de disponibilité dans le Conforama de votre région. Vérification après commande"

  AVAILABILITY_HASH = {
  }

  def initialize url
    @url = url
  end

  def monetize
    @url
  end

  def canonize
    @url
  end

  def process_availability version
    # version[:availability_text] = MerchantHelper::UNAVAILABLE if version[:availability_text].blank?
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO
    version
  end
end
