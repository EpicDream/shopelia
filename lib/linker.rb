class Linker

  UA = "Mozilla/4.0 (compatible; MSIE 7.0; Mac 6.0)"
  
  def self.clean url
    count = 0
    canonical = self.by_rule(url) ||  UrlMatcher.find_by_url(url).try(:canonical) || UrlMatcher.find_by_canonical(url).try(:canonical)
    if canonical.nil?
      orig = url
      begin
        uri = Utils.parse_uri_safely(url)
        res = self.get(uri)
        url = self.ensure_url(res['location'], uri) if res.code =~ /^30/
        count += 1
      end while res.code =~ /^30/ && count < 10

      canonical = self.clean_url url
      UrlMatcher.create(url:orig,canonical:canonical)
    end
    canonical
  rescue
    nil
  end

  def self.monetize url
    return nil if url.blank?
    url = url.unaccent
    m = MerchantConjurer.from_url(url).monetize
  rescue
    merchant = Merchant.find_or_create_by_domain(Utils.extract_domain(url))
    if Incident.where(issue:"Linker",resource_type:"Merchant",resource_id:merchant.id,processed:false).where("description like 'Url not monetized%'").count == 0
      Incident.create(
        :issue => "Linker",
        :resource_type => "Merchant",
        :resource_id => merchant.id,
        :description => "Url not monetized : #{url}",
        :severity => Incident::IMPORTANT)      
    end
    url
  end
  
  private
  
  def self.clean_url url
    canonical = url.gsub(/#.*$/, "")

    domain = Utils.extract_domain(canonical)
    merchant = Merchant.find_by_domain(domain)
    if merchant && merchant.should_clean_args?
      canonical = canonical.gsub(/\?.*$/, "")
    else
      canonical = Utils.strip_tracking_params canonical
    end

    canonical
  end

  def self.get uri
    req = Net::HTTP::Head.new(uri.request_uri, {'User-Agent' => UA })
    res = Net::HTTP.start(uri.host, uri.port, use_ssl:uri.port == 443) { |http| http.request(req) }
    if res.code.to_i == 405 || (res.code.to_i == 200 && res['location'].blank?)
      req = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => UA })
      res = Net::HTTP.start(uri.host, uri.port, use_ssl:uri.port == 443) { |http| http.request(req) }
    end
    res
  end    

  def self.ensure_url url, uri
    if url =~ /^\//
      uri.scheme + "://" + uri.host + url 
    elsif url !~ /^http/
      uri.scheme + "://" + uri.host + "/" + url
    else
      url
    end    
  end

  def self.by_rule url
    if m = url.match(/Xiti_Redirect.htm.*xtloc=([^&]+)/)
      m[1]
    elsif m = url.match(/xiti.*gopc.url.*xtloc=([^&]+)/)
      m[1]      
    else
      nil
    end
  end

end
