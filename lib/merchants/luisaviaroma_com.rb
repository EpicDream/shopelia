# -*- encoding : utf-8 -*-
class LuisaviaromaCom
  DEFAULT_PRICE_SHIPPING = MerchantHelper::FREE_PRICE
  DEFAULT_SHIPPING_INFO = "LUISAVIAROMA.COM expédie dans le monde entier avec les services UPS et DHL."

  AVAILABILITY_HASH = {
  }

  def initialize url
    @url = url
  end

  def monetize
    @url
  end

  def canonize
    @url
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO
    version
  end

  def process_image_url version
    version[:image_url].sub!(/(?<=\.com\/)([A-Za-z]+)(?=\d+)/, "Zoom") if version[:image_url].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/(?<=\.com\/)([A-Za-z]+)(?=\d+)/, "Zoom") }
    version
  end
end
