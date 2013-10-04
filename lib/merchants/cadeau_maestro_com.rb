# -*- encoding : utf-8 -*-
class CadeauMaestroCom

  def initialize url
    @url = url
  end

  # def canonize
  #   if m = @url.match(/cadeau-maestro.com\/(\d+)[\w-]*\/(\d+)-[a-z-]*(\d+).html$/)
  #     "http://www.cadeau-maestro.com/#{m[1]}/#{m[2]}-#{m[3]}.html"
  #   elsif m = @url.match(/cadeau-maestro.com\/(\d+)[\w-]*\/(\d+)[a-z-]*.html$/)
  #     "http://www.cadeau-maestro.com/#{m[1]}/#{m[2]}.html"
  #   else
  #     @url
  #   end
  # end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank?
    version
  end

  def process_shipping_price version
    version[:price_shipping_text] = "4,50 € (à titre indicatif)" if version[:price_shipping_text].blank?
    version
  end
end