class TradedoublerCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /url\((.+?)\)/.match(@url)
      url =  URI.unescape(matches[1])
      url = MerchantHelper.canonize(url)
      return url if url.present?
    end
    @url
  end
end