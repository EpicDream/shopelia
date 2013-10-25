# -*- encoding : utf-8 -*-
class TopgeekNet
  DEFAULT_PRICE_SHIPPING = "5,90 €"
  DEFAULT_SHIPPING_INFO = "Livraison colis privé sous 3 à 5 jours."

  def initialize url
    @url = url
  end

  def canonize
    if m = @url.match(/\/(\d+)-[a-z-]*(\d+).html$/)
      "http://www.topgeek.net/#{m[1]}-#{m[2]}.html"
    else
      @url
    end
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank?
    version
  end

  def process_shipping_price version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end
end