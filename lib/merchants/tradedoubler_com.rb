class TradedoublerCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /url\((.+?)\)/.match(@url)
      url = Linker.decode(matches[1])
      new_url = MerchantHelper.canonize(url)
      return new_url if new_url.present?
      return url unless url =~ /(lengow|jvweb|nonstoppartner)/
    end
    nil
  end
end
