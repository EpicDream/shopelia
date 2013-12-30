# -*- encoding : utf-8 -*-
class PimkieFr < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "5,99 €"
    @free_shipping_limit = 60.0
    @default_shipping_info = "Livraison en Colissimo sous 4 jours."

    @image_sub = [%r{vignette(\w+?)_TH_}, 'zoom\1_HD_']
    @availabilities = {
      /^ACCUEIL.+\(\d+\)$/i => false,
      /^\d+ ARTICLE\(S\).$/i => false,
    }

    @config[:setUnavailableIfEmpty] = true
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
    @config[:subImagesOnly] = true
    @config[:searchBackgroundImageOrColorForOptions] = 1
  end
end
