# -*- encoding : utf-8 -*-
class AmazonFr
  DEFAULT_SHIPPING_PRICE = "2.79 €"

  def initialize url
    @url = url
  end

  def process_availability version
    if version[:availability_text] =~ /Voir les offres de ces vendeurs/
      version[:availability_text] = version[:price_text].present? ? MerchantHelper::AVAILABLE : MerchantHelper::UNAVAILABLE
    end
    version
  end

  def canonize
    if m = @url.match(/\/dp\/([A-Z0-9]+)/)
      "http://www.amazon.fr/dp/#{m[1]}"
    elsif m = @url.match(/\/gp\/product\/([A-Z0-9]+)/)
      "http://www.amazon.fr/gp/product/#{m[1]}"
    else
      nil
    end
  end
 
  def monetize
    if @url.match(/tag=[a-z0-9\-]+/)
      @url.gsub(/tag=[a-z0-9\-]+/, "tag=shopelia-21")
    elsif @url.match(/\?/)
      @url + "&tag=shopelia-21"
    else
      @url + "?tag=shopelia-21"
    end
  end

  def process_price_shipping version
    if version[:price_shipping_text].blank?
      version[:price_shipping_text] = DEFAULT_SHIPPING_PRICE
    elsif version[:price_shipping_text].present? && m = version[:price_shipping_text].match(/livraison gratuite d.s (\d+) euros d'achats/i)
      limit = MerchantHelper.parse_float m[1]
      current_price = MerchantHelper.parse_float version[:price_text]
      if current_price < limit
        version[:price_shipping_text] = DEFAULT_SHIPPING_PRICE
      else
        version[:price_shipping_text] = MerchantHelper::FREE_PRICE
      end
    end
    version
  end
end