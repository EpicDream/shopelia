# -*- encoding : utf-8 -*-
class SpartooCom < MerchantHelper
  def initialize(*)
    super
    @default_shipping_info = "Livraison à domicile standard ( Colissimo ): Délai : 2 à 5 jours. Maximum 5 jours garantis"
    @image_sub = [/_\d+_(?=\w+\.jpg)/i, '_1200_']

    @availabilities = {
      /\d+ articles/i => false,
    }

    @config[:setDefaultShippingInfoAlways] = true
  end

  def process_price_shipping version
    return version unless version[:price_text].present?
    current_price_shipping = MerchantHelper.parse_float version[:price_text]
    return version unless current_price_shipping.kind_of?(Numeric)

    if version[:price_strikeout_text] && current_price_shipping < 80.0
      version[:price_shipping_text] = "5 €"
    elsif version[:price_strikeout_text]
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE
    elsif current_price_shipping < 40.0
      version[:price_shipping_text] = "5 €"
    elsif current_price_shipping < 60.0
      version[:price_shipping_text] = "3 €"
    else
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE
    end
    version
  end

  def process_options version
    return version unless version[:option1] || version[:option2]
    if version[:option1]["text"] =~ /Autres couleurs disponibles/i
      version[:option1].delete("text")
      version[:option1]["src"] = version[:image_url].sub(@image_sub[0], '_40_')
    end
    version
  end
end
