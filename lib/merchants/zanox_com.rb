class ZanoxCom

  def initialize url
    @url = url
  end

  def canonize
    if m = /ULP\=\[\[(.+?)\]\]/.match(@url)
      url = m[1]
      url = "http://#{URI.unescape(url)}" if url =~ /fnac\.com/
      url = "http://www.rueducommerce.fr/m/ps/mpid:#{m[1]}" if m = /mpid\:([A-Za-z0-9\-]+)/.match(@url)
      url = URI.unescape(m[1]) if m = /eurl\=(.+?carrefour.+?html)/.match(url)
      url = m[1] if m = /xtloc\=(http:\/\/www.eveiletjeux.com.+?)\&/.match(url)
   
      url = MerchantHelper.canonize(url)
      return url if url.present?
    end
    nil
  end
end