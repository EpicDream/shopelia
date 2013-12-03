# -*- encoding : utf-8 -*-
class SarenzaCom
  DEFAULT_PRICE_SHIPPING = MerchantHelper::FREE_PRICE
  DEFAULT_SHIPPING_INFO = "Livraison en Colissimo."

  AVAILABILITY_HASH = {
    /\d+ modele/i => false,
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

  def process_availability version
    version[:availability_text] = $~[1] if version[:availability_text] =~ /[^-]*- (.*)$/i
    # version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/(?<=\/)PI(?=_)/, 'HD') }
    version
  end
end
