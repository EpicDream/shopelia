# -*- encoding : utf-8 -*-
class BrandalleyFr
  DEFAULT_PRICE_SHIPPING = "4.90 €"
  FREE_SHIPPING_LIMIT = 60.0

  AVAILABILITY_HASH = {
    'plus que \d+' => true,
  }

  def initialize url
    @url = url
  end

  def canonize
    if m = @url.match(/&eurl=([^&]+)/)
      m[1]
    else
      nil
    end
  end

  def process_availability version
    version[:availability_text] = $~[1] if version[:availability_text] =~ /^taille (?:selectionnee : .+?|unique) - (.*)$/
    version
  end

  def process_price_shipping version
    version[:price_shipping_text] = DEFAULT_PRICE_SHIPPING
    if version[:price_text].present?
      current_price_shipping = MerchantHelper.parse_float version[:price_text]
      version[:price_shipping_text] = MerchantHelper::FREE_PRICE if ! current_price_shipping.nil? && current_price_shipping >= FREE_SHIPPING_LIMIT
    end
    version
  end
end
