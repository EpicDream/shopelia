# -*- encoding : utf-8 -*-
class MycrazystuffCom

  def initialize url
    @url = url
  end

  def process_availability version
    # version[:availability_text] = version[:availability_text] =~ /prochaine exp.dition/i ? "En stock" : "Non disponible"
    version[:availability_text] = "En stock" if version[:availability_text] =~ /prochaine exp.dition/i
    version[:availability_text] = "Non disponible" if version[:availability_text] == ","
    version
  end

  def process_shipping_price version
    version[:price_shipping_text] = "5,80 € (à titre indicatif)" if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = "Livraison Colissimo." if version[:shipping_info].blank?
    version
  end
end