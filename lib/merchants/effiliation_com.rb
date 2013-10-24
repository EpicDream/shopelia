class EffiliationCom

  def initialize url
    @url = url
  end

  def canonize
    matches = /url\=(http.+)/.match(@url)
    return @url unless matches.present?
    url = URI.unescape(matches[1])
    @url = MerchantHelper.canonize(url)
  end

end

