# -*- encoding : utf-8 -*-
class ZalandoFr
  DEFAULT_PRICE_SHIPPING = MerchantHelper::FREE_PRICE

  AVAILABILITY_HASH = {
    "vos modeles preferes" => false,
    "Plus de 1 500 marques" => false,
    /tous les produits d[eu] /i => false,
  }

  def initialize url
    @url = url
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
    version
  end
end