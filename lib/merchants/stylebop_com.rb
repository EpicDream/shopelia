# -*- encoding : utf-8 -*-
class StylebopCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "10.00 €"
    @default_shipping_info = "Livraison UPS en 2-3 jours ouvrables (France)"

    @availabilities = {
      "Recherche par" => false,
      "Top Categories..." => false,
    }

    @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingIfEmpty] = true
    @config[:setDefaultShippingInfoIfEmpty] = true
  end


  def canonize
    if @url =~ /status=404/
      "http://www.stylebop.com/search/noproductsfound.php?status=404"
    else
      @url
    end
  end
end
