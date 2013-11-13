# -*- encoding : utf-8 -*-
class FnacCom

  AVAILABILITY_HASH = {
    "Allez vers la version simple" => false, # pas trouvé, tombe sur la recherche
  }

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url.gsub("http://", ""))
    "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[#{url}]]"
  end

  def canonize
    @url.gsub(/\?.*$/, "").gsub(/#.*$/, "")
  end
end