# -*- encoding : utf-8 -*-
class ZalandoFr < MerchantHelper
  def initialize(*)
    super

    @default_price_shipping = MerchantHelper::FREE_PRICE
    @image_sub = [/(?<=\/)(selector|detail)(?=\/)/, "large"]

    @availabilities = {
      "vos modeles preferes" => false,
      "Plus de 1 500 marques" => false,
      /tous les produits d[eu] /i => false,
      /[\d ]+ articles trouve/i => false,
    }

    @config[:setDefaultPriceShippingIfEmpty] = true
  end
end
