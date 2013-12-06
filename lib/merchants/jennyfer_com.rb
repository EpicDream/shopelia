# -*- encoding : utf-8 -*-
class JennyferCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "5,90€"
    @default_shipping_info = "La livraison se fait entre 3 et 5 jours ouvrés."
    @availabilities = {
    }
    @image_sub = [%r{/(image|thumbnail)/\d+x\d+/}, '/thumbnail/']

    @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end
end
