# -*- encoding : utf-8 -*-
class MajeCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = MerchantHelper::FREE_PRICE
    @default_shipping_info = "Livraison en Colissimo sous 3 jours."

    @image_sub = [%r{(?<=\.jpg)\?.*$}, '']
    @availabilities = {
    }

    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end
end
