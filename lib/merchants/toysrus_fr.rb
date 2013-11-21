class ToysrusFr

  def initialize url
    @url = url
  end

  def monetize
    "http://ad.zanox.com/ppc/?25465502C586468223&ulp=[[http://www.toysrus.fr/redirect_znx.jsp?url=#{@url}&]]"
  end

  def canonize
    if m = URI.unescape(@url).match(/productId=([\d]+)/)
      "http://www.toysrus.fr/product/index.jsp?productId=#{m[1]}"
    else
      nil
    end
  end

  def process_shipping_price version
    version[:price_shipping_text] = "7.20" if version[:price_shipping_text].blank?
    version
  end  
end