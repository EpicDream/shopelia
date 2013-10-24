class ZanoxCom

  def initialize url
    @url = url
  end

  def canonize
    matches = /ULP\=\[\[(.+?)\]\]/.match(@url)
    return @url unless matches.present?
    url = matches[1]
    return "http://#{url}" if url =~ /fnac\.com/
    return @url unless url =~ /http/
    matches = /eurl\=(.+?carrefour.+?html)/.match(url)
    return URI.unescape(matches[1]) if matches.present?
    matches = /\A(http:\/\/www.darty.com.+?html)/.match(url)
    return matches[1] if matches.present?
    matches = /\Ahttp:\/\/www\.toysrus\.fr\/redirect_znx\.jsp\?url=(.+)\Z/.match(url)
    return URI.unescape(matches[1]) if matches.present?
    matches = /\A(http:\/\/www\.imenager\.com.+?)\?/.match(url)
    return URI.unescape(matches[1]) if matches.present?
    matches = /xtloc\=(http:\/\/www.eveiletjeux.com.+?)\&/.match(url)
    return matches[1] if matches.present?
    @url
  end

end
