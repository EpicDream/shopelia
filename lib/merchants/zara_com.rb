# -*- encoding : utf-8 -*-
class ZaraCom
  DEFAULT_PRICE_SHIPPING = "3,95 EUR"
  DEFAULT_SHIPPING_INFO = "En 3-5 jours ouvrables."
  FREE_SHIPPING_LIMIT = 50.0

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
    version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
    if version[:price_text].present?
      current_price_shipping = MerchantHelper.parse_float version[:price_text]
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE if ! current_price_shipping.nil? && current_price_shipping >= FREE_SHIPPING_LIMIT
    end
    version
  end

  def process_shipping_info version
    version[:shipping_info] = MerchantHelper::DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end
end
