# -*- encoding : utf-8 -*-
class AsosCom < MerchantHelper
  def initialize(*)
    super
    @default_price_shipping = MerchantHelper::FREE_PRICE
    @default_shipping_info = "7 jours ouvrés."
    @availabilities = {
      /\d+ styles? found/ => false, # search page
    }
    @image_sub = [/(?<=\d)[a-z]+(?=.je?pg$)/, 'xxl']

    @config[:setAvailableIfEmpty] = true
    @config[:setDefaultPriceShippingAlways] = true
    @config[:setDefaultShippingInfoAlways] = true
  end

  def canonize
    if @url =~ %r{(\w+)\.asos\.com/[^/]+/(\w+)/\?.*(iid=\d+)(?:&|$)}
      "http://#{$~[1]}.asos.com/#{$~[2]}/?#{$~[3]}"
    elsif @url =~ %r{https?://\w+\.asos\.com/Prod/pgeproduct.aspx\?iid=\d+}
      $~[0]
    else
      @url
    end
  end
end
