# -*- encoding : utf-8 -*-
class RueducommerceFr
  FREE_SHIPPING_LIMIT = 300.0
  DEFAULT_SHIPPING_INFO = "Colissimo avec délai de 2 à 4 jours ouvrés."
  DEFAULT_SHIPPING_PRICE = "6.99 €"

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url.gsub("http://", ""))
    "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[#{url}]]"
  end

  def canonize
    @url if @url =~ /mpid/
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank? && ! version[:price_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end

  def process_price_shipping version
    if version[:price_shipping_text].blank?
      version[:price_shipping_text] = DEFAULT_SHIPPING_PRICE
    else
      version[:price_shipping_text] = $~[1] if version[:price_shipping_text] =~ /[aà] partir de (.+)$/i
      current_price_shipping = MerchantHelper.parse_float version[:price_shipping_text]
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE if ! current_price_shipping.nil? && current_price_shipping >= FREE_SHIPPING_LIMIT
    end
    version
  end

  def process_image_url version
    version[:image_url] = nil if version[:image_url] =~ %r{eros/img/ProductSheet/ajax-loader.gif}
    version
  end
end
