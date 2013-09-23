class Linker

  UA = "Mozilla/4.0 (compatible; MSIE 7.0; Mac 6.0)"
  
  def self.clean url
    count = 0
    url = url.unaccent
    canonical = self.by_rule(url) ||  UrlMatcher.find_by_url(url).try(:canonical) || UrlMatcher.find_by_canonical(url).try(:canonical)
    if canonical.nil?
      orig = url
      begin
        begin
          uri = URI.parse(url)
        rescue
          url = url.gsub("%", "")
          uri = URI.parse(url)
        end
        req = Net::HTTP::Head.new(uri.request_uri, {'User-Agent' => UA })
        res = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
        if res.code.to_i == 405 || (res.code.to_i == 200 && res['location'].blank?)
          req = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => UA })
          res = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
        end   
        url = res['location'] if res.code =~ /^30/
        url = url.gsub(" ", "+")
        if url =~ /^\//
          url = uri.scheme + "://" + uri.host + url 
        elsif url !~ /^http/
          url = uri.scheme + "://" + uri.host + "/" + url 
        end
        count += 1
      end while res.code =~ /^30/ && count < 10
      canonical = url.gsub(/#.*$/, "")

      domain = Utils.extract_domain(canonical)
      merchant = Merchant.find_by_domain(domain)
      if merchant && merchant.should_clean_args?
        canonical = canonical.gsub(/\?.*$/, "")
      else
        # Remove all utm_ args
        uri = URI.parse(canonical)
        params = Rack::Utils.parse_nested_query(uri.query).delete_if{|e| e =~ /^utm_/}
        canonical = uri.scheme + "://" + uri.host + uri.path + (params.empty? ? "" : "?" + params.to_query)
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
