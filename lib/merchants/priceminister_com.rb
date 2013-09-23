class PriceministerCom

  def initialize url
    @url = url
  end

  def monetize
    "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=" + @url.gsub(/#.*$/, "")
  end

end