class WebgainsCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /target=(.+?)\Z/.match(@url)
      url =  URI.unescape(matches[1])
      new_url = MerchantHelper.canonize(url)
      return new_url if new_url.present?
      return url unless url =~ /lengow/
    end
    nil
  end
end
