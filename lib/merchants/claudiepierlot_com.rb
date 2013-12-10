# -*- encoding : utf-8 -*-
class ClaudiepierlotCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "6 €"
    @default_shipping_info = "Livraison en Colissimo sous 2-5 jours."

    @image_sub = [%r{/(thumbnail|image)/\d+x(\d+)?/}i, '/image/1000x1465/']
    @availabilities = {
    }

    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end
end
