# -*- encoding : utf-8 -*-
class KookaiFr < MerchantHelper
  def initialize(*)
    super
    @default_shipping_price = "5,95 €"
    @default_shipping_info = "Livraison Rapide en Colissimo du lundi au samedi entre 9h et 12h. Délai moyen de réception : entre 3 et 5 jours ouvrés."
    @image_sub = [/(?<=\-)[VFZ](?=\-\d+\.jpg$)/, 'Z']
    @availabilities = {
    }
    @config[:setDefaultPriceShippingIfEmpty] = true
    @config[:setDefaultShippingInfoIfEmpty] = true
  end

  def canonize
    @url.sub(/\?.+$/, '')
  end
end
