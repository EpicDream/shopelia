# -*- encoding : utf-8 -*-
class LuisaviaromaCom < MerchantHelper
  def initialize(*)
    super

    @default_price_shipping = MerchantHelper::FREE_PRICE
    @default_shipping_info = "LUISAVIAROMA.COM expédie dans le monde entier avec les services UPS et DHL."
    @image_sub = [/(?<=\.com\/)([A-Za-z]+)(?=\d+)/, "Zoom"]

    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end
end
