  # -*- encoding : utf-8 -*-
class SuissesFr
  DEFAULT_PRICE_SHIPPING = "5.95 €"
  DEFAULT_SHIPPING_INFO = "Articles livrés à domicile sous 6 à 8 jours."

  AVAILABILITY_HASH = {
  }

  def initialize url
    @url = url
  end

  def canonize
    if @url =~ /3suisses.fr\/([\w-]+\/)+([\w-]+)(\?.*)?$/
      "http://www.3suisses.fr/"+$~[2]
    else
      @url
    end
  end

  def process_price version
    version[:price_text].sub!(/ ?depuis ?/, '')
    version
  end

  def process_price_strikeout version
    version[:price_strikeout_text] = nil if version[:price_strikeout_text] == "€"
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end
end