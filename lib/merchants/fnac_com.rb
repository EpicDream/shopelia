# -*- encoding : utf-8 -*-
class FnacCom
  DEFAULT_SHIPPING_INFO = "Livraison sous 2 à 3 jours dès expédition de votre commande."
  DEFAULT_SHIPPING_INFO_PRICE = "Frais de port gratuits à partir de 15 € d achat sur les CD, DVD et Blu-Ray. "
  DEFAULT_SHIPPING_INFO_PLUS_PRICE = DEFAULT_SHIPPING_INFO_PRICE + DEFAULT_SHIPPING_INFO

  AVAILABILITY_HASH = {
    "Allez vers la version simple" => false, # pas trouvé, tombe sur la recherche
  }

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url.gsub("http://", ""))
    "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[#{url}]]"
  end

  def canonize
    @url.gsub(/\?.*$/, "").gsub(/#.*$/, "")
  end

  def process_price_shipping version
    version[:price_shipping_text] = MerchantHelper::FREE_PRICE if version[:price_shipping_text] =~ /Livraison rapide offerte/i
    version
  end

  def process_shipping_info version
    if version[:shipping_info].blank? && version[:price_shipping_text].blank?
      version[:shipping_info] = DEFAULT_SHIPPING_INFO_PLUS_PRICE
    elsif version[:shipping_info].blank?
      version[:shipping_info] = DEFAULT_SHIPPING_INFO
    end
    version
  end
end