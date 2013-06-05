class Linker

  def self.monetize url
    url = url.unaccent unless url.nil?
    if url.blank?
      nil
    elsif url.match(/amazon/)
      self.amazon(url)
    elsif url.match(/priceminister/)
      self.price_minister(url)
    else
      url
    end
  end
  
  private
  
  def self.amazon url
    if url.match(/tag=[a-z0-9\-]+/)
      url.gsub(/tag=[a-z0-9\-]+/, "tag=shopelia-21")
    elsif url.match(/\?/)
      url + "&tag=shopelia-21"
    else
      url + "?tag=shopelia-21"
    end
  end  

  def self.price_minister url
    if url.start_with?("http://track.effiliation.com/servlet/effi.redir?id_compteur=11283848")
      url
    elsif url.start_with?("http://track.effiliation.com/servlet/effi.redir?id_compteur=")
      url.gsub(/id_compteur=[0-9]+/, "id_compteur=11283848")
    else
      "http://track.effiliation.com/servlet/effi.redir?id_compteur=11283848&url=" + url.gsub(/#.*$/, "")
    end
  end

end
