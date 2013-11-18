class Linker

  UA = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.76 Safari/537.36"
  
  def self.clean url
    @canonizer = UrlCanonizer.new
    count = 0
    url = URI.unescape(url) if url =~ /^http%3A%2F%2F/
    canonical = MerchantHelper.canonize(url) || self.by_rule(url) || @canonizer.get(url)
    if canonical.nil?
      orig = url
      begin
        uri = Utils.parse_uri_safely(url)
        res = self.get(uri)
        url = self.ensure_url(res['location'], uri) if res.code =~ /^30/
        count += 1
      end while res.code =~ /^30/ && count < 10

      canonical = self.clean_url url
      @canonizer.set(orig, canonical)
      @canonizer.set(canonical, canonical)
    end
    canonical
  rescue Errno::ETIMEDOUT
    orig || url
  rescue
    orig || url
  end

  def self.monetize url
    return nil if url.blank?
    url = url.unaccent
    url_m = MerchantHelper.monetize(url)
    raise if url_m.blank?
    url_m 
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

    MerchantHelper.canonize(canonical) || canonical
  end

  def self.get uri
    req = Net::HTTP::Head.new(uri.request_uri, {'User-Agent' => UA })
    res = Net::HTTP.start(uri.host, uri.port, use_ssl:uri.port == 443) { |http| http.request(req) }
    if res.code.to_i == 405 || (res.code.to_i == 200 && res['location'].blank?)
      req = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => UA })
      req["accept-encoding"] = "gzip"
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
