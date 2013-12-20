# -*- encoding : utf-8 -*-
class ZaraCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "3,95 EUR"
    @free_shipping_limit = 50.0
    @default_shipping_info = "En 3-5 jours ouvrables."

    @availabilities = {
      "No results have been found" => false,
      "Results for:" => false,
    }

    @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingIfEmpty] = true
    @config[:setDefaultShippingInfoIfEmpty] = true
  end
end
