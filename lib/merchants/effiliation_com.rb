class EffiliationCom

  def initialize url
    @url = url
  end

  def canonize
    if m = /url\=(http.+)/.match(@url)
      MerchantHelper.canonize(URI.unescape(m[1]))
    else
      nil
    end
  end
end