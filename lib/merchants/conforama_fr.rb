# -*- encoding : utf-8 -*-
class ConforamaFr
  DEFAULT_PRICE_SHIPPING = "8 €"
  DEFAULT_SHIPPING_INFO = "Colis Privé"

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
    version[:shipping_info] = MerchantHelper::DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end
end
