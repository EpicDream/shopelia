# -*- encoding : utf-8 -*-
class SephoraFr
  DEFAULT_PRICE_SHIPPING = "3,95 €"
  DEFAULT_SHIPPING_INFO = "Livraison Colissimo en 3-5 jours ouvrables."
  FREE_SHIPPING_LIMIT = 60.0

  def initialize url
    @url = url
  end

  def process_price_shipping version
    if version[:price_shipping_text].blank? && version[:price_text].present?
      limit = MerchantHelper.parse_float(version[:price_text])
      if limit < FREE_SHIPPING_LIMIT
        version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
      else
        version[:price_shipping_text] = MerchantHelper::FREE_PRICE
      end
    end
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end
end