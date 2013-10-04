# -*- encoding : utf-8 -*-
class MonamenagementjardinFr

  def initialize url
    @url = url
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank?
    version
  end

  def process_shipping_price version
    version[:price_shipping_text] = "LIVRAISON GRATUITE"
    version
  end
end