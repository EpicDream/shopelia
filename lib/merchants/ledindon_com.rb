# -*- encoding : utf-8 -*-
class LedindonCom

  def initialize url
    @url = url
  end

  def process_shipping_price version
    version[:price_shipping_text] = "6,50 € (à titre indicatif)" if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = "Livraison Colissimo 48h. " + version[:shipping_info]
    version
  end
end