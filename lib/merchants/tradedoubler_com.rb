class TradedoublerCom

  def initialize url
    @url = url
  end

  def canonize
    matches = /url\((.+?)\)/.match(@url)
    return URI.unescape(matches[1]) if matches.present?
    @url
  end

end

