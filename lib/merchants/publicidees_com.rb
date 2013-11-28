class PublicideesCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /url=(.+)\Z/.match(@url)
      url =  URI.unescape(matches[1])
      new_url = MerchantHelper.canonize(url)
      return new_url if new_url.present?
      return url unless url =~ /lengow/ || url =~ /jvweb/
    end
    nil
  end
end
