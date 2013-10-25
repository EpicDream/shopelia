class CdiscountCom

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url)
    "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(765856165)ttid(5)url(#{url})"
  end

  def canonize
    if m = /sku=([A-Za-z0-9]+)/.match(@url)
			"http://www.cdiscount.com/dp.asp?sku=#{m[1]}"
    else
      nil
    end
  end

  def process_availability version
    version[:availability_text] = "Indisponible" if version[:shipping_info] =~ /en magasin/i
    version
  end
end
