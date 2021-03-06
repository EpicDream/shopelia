# -*- encoding : utf-8 -*-
class AsosFr
  DEFAULT_PRICE_SHIPPING = "Livraison gratuite"
  DEFAULT_SHIPPING_INFO = "Sous 6 jours ouvrables"

  AVAILABILITY_HASH = {
    /\d+-\d+ of \d+/i => false, # search page
    /\d+ style\(s\) trouve\(s\)/i => false, # search page
  }

  def initialize url
    @url = url
  end

  def canonize
    @url = @url.gsub("http://www.asos.fr/www.asos.fr", "http://www.asos.fr")
    if @url =~ %r{asos.fr/[^/]+/(\w+)/\?.*(iid=\d+)}
      "http://www.asos.fr/#{$~[1]}/?#{$~[2]}"
    elsif @url =~ %r{pgeproduct.aspx.*iid=(\d+)}
      "http://www.asos.fr/pgeproduct.aspx?iid=#{$~[1]}"
    else
      @url
    end
  end

  def monetize
    @url
  end

  def process_availability version
    version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end

  def process_image_url version
    version[:image_url].sub!(/(?<=\d)[a-z]+(?=.je?pg$)/, 'xxl') if version[:image_url].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/(?<=\d)[a-z]+(?=.je?pg$)/, 'xxl') }
    version
  end
end
