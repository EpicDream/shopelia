class RueducommerceFr

  def initialize url
    @url = url
  end

  def monetize
    url = CGI::escape(@url.gsub("http://", ""))
    "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[#{url}]]"
  end

  def canonize
    @url if @url =~ /mpid/
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text].blank? && ! version[:price_text].blank?
    version
  end
end