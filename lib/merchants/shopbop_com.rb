# -*- encoding : utf-8 -*-
class ShopbopCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "10 €"
    @default_shipping_info = "Livraison à domicile"
    @free_shipping_limit = 75.0 # euros, en fait $100
    @image_sub = [/_\d+x\d+(?=\.jpg)/i, '']

    @availabilities = {
      /\d+ item/i => false,
    }
    
    # @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end

  def canonize
    @url.sub(/\?.*$/, '')
  end
end
