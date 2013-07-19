class Linker

  UA = "Mozilla/4.0 (compatible; MSIE 7.0; Mac 6.0)"
  
  def self.clean url
    count = 0
    url = url.unaccent
    canonical = UrlMatcher.find_by_url(canonical).try(:canonical) || UrlMatcher.find_by_url(url).try(:canonical)
    if canonical.nil?
      orig = url
      begin
        uri = URI.parse(url)
        req = Net::HTTP::Head.new(uri.request_uri, {'User-Agent' => UA })
        res = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
        if res.code.to_i == 405
          req = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => UA })
          res = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
        end   
        url = res['location'] if res.code =~ /^30/
        url = url.gsub(" ", "+")
        url = uri.scheme + "://" + uri.host + url if url =~ /^\//
        count += 1
      end while res.code =~ /^30/ && count < 10
      canonical = url.gsub(/#.*$/, "").gsub(/\?.*$/, "")
      UrlMatcher.create(url:orig,canonical:canonical)
    end
    canonical
    rescue Exception => e
      nil
  end

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
    elsif url.match(/rueducommerce/)
      self.rueducommerce(url)
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
      url.gsub(/\?[^&]+&/, "?25134383C1552684717T&")
    else 
      url = CGI::escape(url.gsub("http://", ""))
      "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[#{url}]]"
    end
  end
  
  def self.rueducommerce url
    url = CGI::escape(url.gsub("http://", ""))
    "http://ad.zanox.com/ppc/?25390102C2134048814&ulp=[[#{url}]]"
  end

end
