# -*- encoding : utf-8 -*-
class NordstromCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = MerchantHelper::FREE_PRICE
    @default_shipping_info = "Livraison et retour gratuits. Livraison en 5 à 13 jour ouvrés."
    @image_sub = [%r{(?<=/)large|mini(?=/)}i, 'zoom']

    @availabilities = {
      /[\d,]+item/i => false,
    }
    
    # @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end

  def canonize
    @url.sub(/\?.*$/, '')
  end
end
