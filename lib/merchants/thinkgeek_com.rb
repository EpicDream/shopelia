# -*- encoding : utf-8 -*-
class ThinkgeekCom

  def initialize url
    @url = url
  end

  def canonize
    if m = @url.match(/\.com\/product\/(\w+)\//)
      "http://www.thinkgeek.com/product/#{m[1]}/"
    elsif m = @url.match(/.com\/stuff/)
      @url
    else
      nil
    end
  end

  def process_availability version
    case version[:availability_text]
    when "" then version[:availability_text] = "En stock"
    when /^future/ then version[:availability_text] = "Non disponible"
    when /^peter jackson-y/ then version[:availability_text] = "Non disponible"
    end
    version
  end

  def process_price version
    version[:price_text] = nil if version[:price_text] == "n/a"
    version
  end

  def process_shipping_price version
    version[:price_shipping_text] = "27,50 $ (à titre indicatif)" if version[:price_shipping_text].blank?
    version
  end
end