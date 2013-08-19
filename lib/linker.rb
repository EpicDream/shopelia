class Linker

  UA = "Mozilla/4.0 (compatible; MSIE 7.0; Mac 6.0)"
  
  def self.clean url
    count = 0
    url = url.unaccent
    canonical = self.by_rule(url) || UrlMatcher.find_by_url(canonical).try(:canonical) || UrlMatcher.find_by_url(url).try(:canonical)
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
      canonical = url.gsub(/#.*$/, "")

      domain = Utils.extract_domain(canonical)
      merchant = Merchant.find_by_domain(domain)
      if merchant && merchant.should_clean_args?
        canonical = canonical.gsub(/\?.*$/, "")
      end
      
      UrlMatcher.create(url:orig,canonical:canonical)
    end
    canonical
    rescue Exception => e
      nil
  end

  def self.monetize url
    return nil if url.blank?
    url = url.unaccent
    MerchantConjurer.from_url(url).monetize
  rescue
    Incident.create(
      :issue => "Linker",
      :description => "Url not monetized : #{url}",
      :severity => Incident::IMPORTANT)      
    url
  end
  
  private
  
  def self.by_rule url
    if m = url.match(/Xiti_Redirect.htm.*xtloc=([^&]+)/)
      m[1]
    else
      nil
    end
  end

end
