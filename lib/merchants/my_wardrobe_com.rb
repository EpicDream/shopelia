# -*- encoding : utf-8 -*-
class MyWardrobeCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = "11 £"
    @default_shipping_info = "Livraison 2 à 4 jour ouvrés."
    @image_sub = [%r{(?<=/)s|p(?=\d_\d+)}i, 'm']

    @availabilities = {
      "SORT BY" => false,
    }
    
    @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end

  def process_availability version
    if version[:availability_text].blank? && version[:option1].kind_of?(Hash) && version[:option1]["text"] =~ /\((.*?)\)/i
      version[:availability_text] = $~[1]
      version[:option1]["text"].sub!(/\s*\((.*?)\)/i, '')
    else
      super
    end
    version
  end
end
