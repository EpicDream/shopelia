class PriceministerCom

  AVAILABILITY_HASH = {
    "[\d\s]+ r.sultats?" => false, # Redirection vers recherche quand trouve pas.
  }

  def initialize url
    @url = url
  end

  def monetize
    "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=" + CGI::escape(@url.gsub(/#.*$/, ""))
  end

  def canonize
    matches = /(http:\/\/www.priceminister.com\/offer\/buy\/\d+)/.match(@url)
    return matches[1] if matches.present?
    @url
  end

  def process_availability version
    version[:availability_text] = MerchantHelper::AVAILABLE if version[:availability_text].blank?
    version
  end

end
