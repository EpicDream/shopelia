# -*- encoding : utf-8 -*-
class GalerieslafayetteCom
  DEFAULT_PRICE_SHIPPING = "2.90 €"
  DEFAULT_SHIPPING_INFO = "Livraison Rapide Colissimo, 2-3 jours d’expédition"
  FREE_SHIPPING_LIMIT = 100.0

  AVAILABILITY_HASH = {
  }

  def initialize url
    @url = url
  end

  def canonize
    if @url =~ %r{galerieslafayette.com/p(?:/[^/]+)?/(\d+/\d+)(?:\?.+)?$}
      "http://www.galerieslafayette.com/p/" + $~[1]
    elsif @url =~ %r{galerieslafayette.com/a(?:/[^/]+)?/(\d+)(?:\?.+)?$}
      "http://www.galerieslafayette.com/a/" + $~[1]
    else
      @url
    end
  end

  def process_availability version
    version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
    if version[:price_text].present?
      current_price_shipping = MerchantHelper.parse_float version[:price_text]
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE if ! current_price_shipping.nil? && current_price_shipping >= FREE_SHIPPING_LIMIT
    end
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end
end
