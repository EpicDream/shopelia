# -*- encoding : utf-8 -*-
class SonVideoCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "9,90€"
    @default_shipping_info = "Livraison SoColissimo, entre 2 et 3 jours ouvrés."
    @availabilities = {
      "Delai : nous contacter" => false,
    }
    @image_sub = [%r{(?<=_)\d+(?=\.jpg$)}, '500']

    @config[:setDefaultPriceShippingIfEmpty] = true
    @config[:setDefaultShippingInfoIfEmpty] = true
    @config[:subImagesOnly] = true
  end
end
