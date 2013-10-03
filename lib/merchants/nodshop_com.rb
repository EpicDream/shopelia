# -*- encoding : utf-8 -*-
class NodshopCom

  def initialize url
    @url = url
  end

  def canonize
    if m = @url.match(/nodshop.com\/[\w-]+\/(\d+[a-z-]*).html$/)
      "http://www.nodshop.com/#{m[1]}.html"
    else
      @url
    end
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank?
    version
  end

  def process_shipping_price version
    version[:price_shipping_text] = "4,90 € (à titre indicatif)" if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = "Livraison Colissimo 48h en France Metropolitaine." if version[:shipping_info].blank?
    version
  end
end