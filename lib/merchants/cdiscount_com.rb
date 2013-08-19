class CdiscountCom

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url)
    "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(765856165)ttid(5)url(#{url})"
  end

end