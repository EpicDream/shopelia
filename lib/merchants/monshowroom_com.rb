class MonshowroomCom
  DEFAULT_PRICE_SHIPPING = "7 €"
  DEFAULT_SHIPPING_INFO = " Livraison So Colissimo en 2 à 5 jours. "
  FREE_SHIPPING_LIMIT = 89.0

  AVAILABILITY_HASH = {
  }

  def initialize url
    @url = url
  end

  def canonize
    if matches = /eurl=(.+)\Z/.match(@url)
      url =  URI.unescape(matches[1])
      url.gsub!(/\?.+\Z/, '')
      return url
    end
    @url
  end
  
  def monetize
    @url
  end

  def process_availability version
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
    if version[:price_text].present?
      current_price_shipping = MerchantHelper.parse_float version[:price_text]
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE if ! current_price_shipping.nil? && current_price_shipping >= FREE_SHIPPING_LIMIT
    end
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO + version[:shipping_info]
    version
  end

  def process_image_url version
    version[:image_url].sub!(/\-[a-z]\.je?pg.*$/, '-e.jpg') if version[:image_url].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/\-[a-z]\.je?pg.*$/, '-e.jpg') }
    version
  end

  def process_options version
    if version[:option1].present? && version[:option1]["text"].blank? &&
      version[:option1]["src"].blank? && version[:option1]["style"].present? &&
      version[:option1]["style"] =~ /background(?:-color)?\s*:\s*(#?\w+)\s*;/i
      version[:option1]["text"] = $~[1]
    end
    version
  end
end
