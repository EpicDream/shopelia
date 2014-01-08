# -*- encoding : utf-8 -*-
class NikeCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "5 €"
    @default_shipping_info = "3 jours ouvrés."
    @availabilities = {
      /\d+ ARTICLES/i => false,
      /\d+ PRODUCTS/i => false,
    }
    @image_sub = [/(?<=wid=|hei=)\d+(?=&)/, '1860']

    @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end
end
