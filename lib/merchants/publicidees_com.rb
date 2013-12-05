class PublicideesCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /url=(.+)\Z/.match(@url)
      url =  URI.unescape(matches[1])
      new_url = MerchantHelper.canonize(url)
      return new_url if new_url.present?
      return url unless MerchantHelper.is_aggregator?(url)
    end
    nil
  end
end
