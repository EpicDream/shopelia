class WebgainsCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /target=(.+?)\Z/.match(@url)
      url = URI.unescape(matches[1])
      return url unless url =~ /lengow/ 
    end
    nil
  end
end
