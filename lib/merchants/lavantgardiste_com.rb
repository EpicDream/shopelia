# -*- encoding : utf-8 -*-
class LavantgardisteCom

  def initialize url
    @url = url
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank?
    version
  end

  def process_shipping_price version
    version[:price_shipping_text] = "4,50 € (à titre indicatif)" if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = "Livraison Colissimo." if version[:shipping_info].blank?
    version
  end
end