# -*- encoding : utf-8 -*-
class PixmaniaFr
  DEFAULT_PRICE_SHIPPING = "5,99 €"
  DEFAULT_SHIPPING_INFO = "Colis Privé vous livre en 4 à 6 jours ouvrés du lundi au vendredi de 8h à 18h."

  AVAILABILITY_HASH = {
    "affiner votre recherche" => false
  }

  def initialize url
    @url = url
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank? || version[:price_shipping_text] =~ /Modes de livraison/i
    version
  end

  def process_shipping_info version
    version[:shipping_info] = DEFAULT_SHIPPING_INFO if version[:shipping_info].blank?
    version
  end

  def process_image_url version
    version[:image_url].sub!(%r{/\w(_\d+\.\w+)$}, '/l\\1') if version[:image_url].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(%r{/\w(_\d+\.\w+)$}, '/l\\1') }
    version
  end
end