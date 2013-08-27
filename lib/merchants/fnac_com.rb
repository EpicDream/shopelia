class FnacCom

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url.gsub("http://", ""))
    "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[#{url}]]"
  end

end