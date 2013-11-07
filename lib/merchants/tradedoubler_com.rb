class TradedoublerCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /url\((.+?)\)/.match(@url)
      url =  URI.unescape(matches[1])
      new_url = MerchantHelper.canonize(url)
      return new_url if new_url.present?
    end
    nil
  end
end