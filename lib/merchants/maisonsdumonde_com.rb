# -*- encoding : utf-8 -*-
class MaisonsdumondeCom < MerchantHelper
  def initialize(*)
    super
    @default_shipping_info = "SoColissimo. En moyenne, 3 jours ouvrés pour les articles en stock."
    @image_sub = [/_w48_h48(?=\.jpg$)/, '_w310_h310']
    @availabilities = {
    }
    @config[:setDefaultShippingInfoIfEmpty] = true
    @config[:subImagesOnly] = true
  end

  def canonize
    @url.sub(/\?.+$/, '')
  end

  def process_price_shipping version
    return version if version[:price_text].blank?
    price = MerchantHelper.parse_float version[:price_text]
    version[:price_shipping_text] = case price
      when 0...50 then "5,90 € TTC"
      when 50...100 then "9,00 € TTC"
      when 100...200 then "19,00 € TTC"
      when 200...300 then "29,00 € TTC"
      when 300...500 then "39,00 € TTC"
      when 500...1000 then "59,00 € TTC"
      else MerchantHelper::FREE_PRICE
    end
    version
  end
end
