# -*- encoding : utf-8 -*-
class NetAPorterCom
  DEFAULT_PRICE_SHIPPING = "15 €"
  DEFAULT_SHIPPING_INFO = "Livraison entre 9h et 17h, du lundi au vendredi. Réception de vos articles 3 à 4 jours ouvrés après la date de votre commande"

  AVAILABILITY_HASH = {
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
    # version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING if version[:price_shipping_text].blank?
    version
  end

  def process_shipping_info version
    version[:shipping_info] = version[:shipping_info].gsub(/(?<=.)\.?$/, ". ") + DEFAULT_SHIPPING_INFO if version[:shipping_info].present?
    version
  end

  def process_images version
    return version unless version[:images].kind_of?(Array)
    version[:images].map! { |url| url.sub(/(?<=_)[a-z]+(?=.je?pg$)/, 'xl') }
    version
  end
end
