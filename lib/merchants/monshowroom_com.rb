class MonshowroomCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /eurl=(.+)\Z/.match(@url)
      url =  URI.unescape(matches[1])
      url.gsub!(/\?.+\Z/, '')
      return url
    end
    @url
  end
end
