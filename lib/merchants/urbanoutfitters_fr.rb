# -*- encoding : utf-8 -*-
class UrbanoutfittersFr
  DEFAULT_PRICE_SHIPPING = "4,90 €"
  DEFAULT_SHIPPING_INFO = "Livrée en 3-5 jours ouvrables."
  FREE_SHIPPING_LIMIT = 75.0

  AVAILABILITY_HASH = {
    /\d+ article\(s\) trouve\(s\)/i => false,
  }

  def initialize url
    @url = url
  end

  def canonize
    @url
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
    if version[:price_text].present?
      current_price_shipping = MerchantHelper.parse_float version[:price_text]
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE if ! current_price_shipping.nil? && current_price_shipping >= FREE_SHIPPING_LIMIT
    end
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end

  def process_image_url version
    version[:image_url].sub!(/(?<=_)\w(?=\d+\.jpe?g)/, 'z') if version[:image_url].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/(?<=_)\w(?=\d+\.jpe?g)/, 'z') }
    version
  end
end
