class Linker

  def self.monetize url
    url = url.unaccent unless url.nil?
    if url.blank?
      nil
    elsif url.match(/amazon/)
      self.amazon(url)
    elsif url.match(/priceminister/)
      self.price_minister(url)
    elsif url.match(/fnac/)
      self.fnac(url)
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

  def self.fnac url
    if url.include? "zanox"
      uri = URI.parse(url)
      response = nil
      while response.nil? || response.code.to_i != 200 do
        req = Net::HTTP::Get.new(uri.request_uri)
        response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
        uri = URI.parse(response['location']) unless response.code.to_i == 200
      end
      url = uri.to_s
    end
    url = CGI::escape(url.gsub("http://", ""))
    "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[#{url}]]"
  end

end
