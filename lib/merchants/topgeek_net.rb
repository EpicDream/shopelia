# -*- encoding : utf-8 -*-
class TopgeekNet

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
    version[:price_shipping_text] = "3,90 € (à titre indicatif)" if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = "Livraison SoColissimo." if version[:shipping_info].blank?
    version
  end
end