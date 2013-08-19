class ToysrusFr

  def initialize url
    @url = url
  end

  def monetize
    "http://ad.zanox.com/ppc/?25465502C586468223&ulp=[[http://www.toysrus.fr/redirect_znx.jsp?url=#{@url}&]]"
  end

end