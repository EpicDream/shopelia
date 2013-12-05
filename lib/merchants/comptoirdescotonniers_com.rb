# -*- encoding : utf-8 -*-
class ComptoirdescotonniersCom < MerchantHelper
  def initialize(*)
    super
    @default_shipping_price = "5,95 €"
    @default_shipping_info = "Livraison en Colissimo. Préparation de votre commande en 48h à 72h et en maximum 10 jours ouvrés en périodes de forte activité telles que les Soldes, Noël, etc,."
    @image_sub = [%r{(?<=article/)\d+x\d+(?=/\d+.jpg$)}, '940x940']
    @availabilities = {
    }

    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoIfEmpty] = true
    @config[:addDefaultShippingInfoBefore] = true
    @config[:subImagesOnly] = true
  end

  def canonize
    @url.sub(/\?.+$/, '')
  end
end
