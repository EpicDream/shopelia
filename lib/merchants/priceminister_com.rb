class PriceministerCom

  def initialize url
    @url = url
  end

  def monetize
    "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=" + @url.gsub(/#.*$/, "")
  end

  def canonize
    matches = /(http:\/\/www.priceminister.com\/offer\/buy\/\d+)/.match(@url)
    return matches[1] if matches.present?
    @url
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank?
    version
  end

end
