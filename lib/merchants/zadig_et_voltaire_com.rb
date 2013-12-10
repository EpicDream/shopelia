# -*- encoding : utf-8 -*-
class ZadigEtVoltaireCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "10 €"
    @default_shipping_info = "Livraison UPS en 1 à 2 jours."

    @image_sub = [%r{/(thumbnail|image)/\d+x(\d+)?/}i, '/image/']
    @availabilities = {
    }

    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end
end
