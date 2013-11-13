# -*- encoding : utf-8 -*-
class ThebodyshopFr
  DEFAULT_PRICE_SHIPPING = "5.95"
  FREE_PRICE_SHIPPING_LIMIT = 40.0

  def initialize url
    @url = url
  end

  def process_availability version
    version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_shipping_price version
    if version[:price_text].present?
      current_price = MerchantHelper.parse_float version[:price_text]
      if current_price < FREE_PRICE_SHIPPING_LIMIT
        version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
      else
        version[:price_shipping_text] = MerchantHelper::FREE_PRICE
      end
    end
    version
  end
end