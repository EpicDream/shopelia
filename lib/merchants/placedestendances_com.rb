# -*- encoding : utf-8 -*-
class PlacedestendancesCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "5.00 €"
    @default_shipping_info = "Livraison So Colissimo en 2-3 jours ouvrables (France)"
    @free_shipping_limit = 90.0
    @image_sub = [/\.\d+(?=\.jpg)/i, '']

    @availabilities = {
      /\d+ modeles/i => false,
    }

    # @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end

  def process_options version
    return version unless version[:option1] || version[:option2]
    if version[:option1]["text"] =~ /Colori/i
      version[:option1]["text"].sub(/Coloris? :/i, '')
      version[:option1]["src"] = version[:image_url].sub(/(\.\d+)?\.jpg/i, '.36.jpg')
    end
    version
  end
end
