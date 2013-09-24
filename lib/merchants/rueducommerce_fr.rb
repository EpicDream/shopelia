class RueducommerceFr

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url.gsub("http://", ""))
    "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[#{url}]]"
  end

end