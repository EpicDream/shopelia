class ZanoxCom

  def initialize url
    @url = url
  end

  def canonize
    if m = /ULP\=\[\[(.+?)\]\]/.match(@url)
      url = m[1]
      url = "http://#{url}" if url =~ /fnac\.com/
      url = URI.unescape(m[1]) if m = /eurl\=(.+?carrefour.+?html)/.match(url)
      url = m[1] if m = /xtloc\=(http:\/\/www.eveiletjeux.com.+?)\&/.match(url)
   
      url = MerchantHelper.canonize(url)
      @url = url if url.present?
    end
    @url
  end
end