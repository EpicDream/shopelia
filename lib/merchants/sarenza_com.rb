# -*- encoding : utf-8 -*-
class SarenzaCom < MerchantHelper

  def initialize(*)
    super
    @default_price_shipping = MerchantHelper::FREE_PRICE
    @default_shipping_info = "Livraison en Colissimo."
    @availabilities = {
      /\d+ modele/i => false,
      "TOUTES LES MARQUES" => false,
    }
    @image_sub = [/(?<=\/)PI(?=_)/, 'HD']

    # @config[:setAvailableIfEmpty] = true,
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
    @config[:subImagesOnly] = true
  end

  def process_availability version
    # version = super version
    version[:availability_text] = $~[1] if version[:availability_text] =~ /[^-]*- (.*)$/i
    version
  end
end
