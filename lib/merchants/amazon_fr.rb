# -*- encoding : utf-8 -*-
require 'parsers/descriptions/formatter'

class AmazonFr
  DEFAULT_PRICE_SHIPPING = "2.79 €"
  DEFAULT_SHIPPING_INFO_1 = "Prix et délais variables en fonction du vendeur."
  DEFAULT_SHIPPING_INFO_2 = "Délais variables en fonction du vendeur."

  AVAILABILITY_HASH = {
    /TVA incluse le cas .ch.ant/i => false, # vu juste pour des MP3 à télécharger
  }

  def initialize url
    @url = url
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

  def process_availability version
    if version[:availability_text] =~ /Voir les offres de ces vendeurs/i
      version[:availability_text] = version[:price_text].present? ? MerchantHelper::AVAILABLE : MerchantHelper::UNAVAILABLE
    end
    version
  end

  def process_price_shipping version
    if version[:price_shipping_text].blank?
      version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
    elsif version[:price_shipping_text].present? && m = version[:price_shipping_text].match(/livraison gratuite d.s (\d+) euros d'achats/i)
      limit = MerchantHelper.parse_float m[1]
      current_price = MerchantHelper.parse_float version[:price_text]
      if current_price < limit
        version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
      else
        version[:price_shipping_text] = MerchantHelper::FREE_PRICE
      end
    end
    version
  end

  def process_shipping_info version
    version[:shipping_info] = nil if version[:shipping_info] =~ /Voir les offres de ces vendeurs/i
    if version[:shipping_info].blank?
      prc_shp_txt = version[:price_shipping_text]
      version[:shipping_info] = prc_shp_txt.blank? || prc_shp_txt == DEFAULT_PRICE_SHIPPING ? DEFAULT_SHIPPING_INFO_1 : DEFAULT_SHIPPING_INFO_2
    end
    version
  end

  def process_images version
    #TODO: faire la meme chose pour image_url, mais elle peut être vraiment grande...
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/\._.+?_\.(\w+)$/, '.\\1') }
    version
  end
  
  def process_description version
    # version[:json_description] = Descriptions::Formatter.format(version[:description], @url)
    version
  end
end