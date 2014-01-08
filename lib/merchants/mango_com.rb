# -*- encoding : utf-8 -*-
class MangoCom < MerchantHelper
  def initialize(*)
    super

    @default_price_shipping = "2 € 95"
    @default_shipping_info = "Sous 3 à 6 jours."
    @free_shipping_limit = 30.0
    @image_sub = [/(?<=fotos\/)S\d+(?=\/\d+)/, 'S20']

    @availabilities = {
      "ORDER BY PRICE" => false,
    }

    @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingIfEmpty] = true
    @config[:setDefaultShippingInfoIfEmpty] = true
  end
end
