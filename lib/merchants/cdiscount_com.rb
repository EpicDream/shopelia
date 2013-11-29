# -*- encoding : utf-8 -*-
class CdiscountCom
  DEFAULT_PRICE_SHIPPING = "2.99 €"
  DEFAULT_SHIPPING_INFO = "A partir de 1 jour ouvré pour les produits <= 30 kg en stock, à partir de 4 jours ouvrés pour les produits volumineux en stock."
  DEFAULT_SHIPPING_INFO_PRICE = "2€99 pour les produits <= 30 kg, 19€99 pour les produits volumineux. "
  DEFAULT_SHIPPING_INFO_PLUS_PRICE = DEFAULT_SHIPPING_INFO_PRICE + DEFAULT_SHIPPING_INFO

  AVAILABILITY_HASH = {
    "operation commerciale" => false,
    "toute l’offre" => false,
  }

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url)
    "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(765856165)ttid(5)url(#{url})"
  end

  def canonize
    if m = /sku=([A-Za-z0-9\_\-]+)/.match(@url)
			"http://www.cdiscount.com/dp.asp?sku=#{m[1]}"
    else
      nil
    end
  end

  def process_availability version
    version[:availability_text] = MerchantHelper::UNAVAILABLE if version[:shipping_info] =~ /en magasin/i
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
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

  def process_image_url version
    version[:image_url].sub!(%r{/\d\d\dx\d\d\d/}, '/700x700/') if version[:image_url].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(%r{/\d\d\dx\d\d\d/}, '/700x700/') }
    version
  end
end
