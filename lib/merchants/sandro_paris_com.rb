# -*- encoding : utf-8 -*-
class SandroParisCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = MerchantHelper::FREE_PRICE
    @default_shipping_info = "Livraison Colissimo."

    @image_sub = [%r{\.\d+(?=\.jpg$)}i, '']
    @availabilities = {
    }

    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end
end
