# -*- encoding : utf-8 -*-
class BhdiscountCom
  DEFAULT_PRICE_SHIPPING = "10 €"

  AVAILABILITY_HASH = {
    "Delais produit" => true,
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
end
