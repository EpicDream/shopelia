# -*- encoding : utf-8 -*-
class GalerieslafayetteCom < MerchantHelper

  def initialize(*)
    super
    @default_price_shipping = "2.90 €"
    @default_shipping_info = "Livraison Rapide Colissimo, 2-3 jours d’expédition"
    @free_shipping_limit = 100.0
    @availabilities = {
      /\d+ article/i => false,
    }
    @image_sub = [%r{(?<=\d_)[A-Z]+(?=_\d+\.jpg$)}, 'ZP']

    @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingIfEmpty] = true
    @config[:setDefaultShippingInfoIfEmpty] = true
  end

  def canonize
    if @url =~ %r{galerieslafayette.com/p(?:/[^/]+)?/(\d+/\d+)(?:\?.+)?$}
      "http://www.galerieslafayette.com/p/" + $~[1]
    elsif @url =~ %r{galerieslafayette.com/a(?:/[^/]+)?/(\d+)(?:\?.+)?$}
      "http://www.galerieslafayette.com/a/" + $~[1]
    else
      @url
    end
  end
end
