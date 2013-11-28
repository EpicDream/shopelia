# -*- encoding : utf-8 -*-
class TopshopCom
  DEFAULT_PRICE_SHIPPING = "6 €"
  DEFAULT_SHIPPING_INFO = "Livrée en 5 jours ouvrables."

  AVAILABILITY_HASH = {
  }

  def initialize url
    @url = url
  end

  def canonize
    if @url =~ %r{topshop.com/fr/tsfr/produit/(?:(?:[\w-]|%[0-9A-F]{2})+-\d+/)*((?:[\w-]|%[0-9A-F]{2})+-\d+)(?:\?|$)}
      "http://fr.topshop.com/fr/tsfr/produit/#{$~[1]}"
    else
      @url
    end
  end

  def monetize
    @url
  end

  def process_availability version
    # version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
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
    version[:image_url].sub!(/(?<=_)(small|normal)(?=\.jpe?g)/, 'large') if version[:image_url].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/(?<=_)(small|normal)(?=\.jpe?g)/, 'large') }
    version
  end
end
