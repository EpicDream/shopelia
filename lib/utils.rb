class Utils

  def self.extract_domain url
    host = self.parse_uri_safely(url).host
    host.gsub(/^(?:\w+:\/\/)?[^:?#\/\s]*?([^.\s]+\.(?:[a-z]{2,}|co\.uk|org\.uk|ac\.uk|org\.au|com\.au))(?:[:?#\/]|$)/, '\1')
  end

  def self.parse_uri_safely url
    URI.parse(url.encode('UTF-8', 'UTF-8', :invalid => :replace).scan(/([!\#$&-;=?-\[\]_a-z~]|%[0-9a-fA-F]{2})/).join)
  end

  def self.strip_tracking_params url
    uri = self.parse_uri_safely(url)
    params = Rack::Utils.parse_nested_query(uri.query).delete_if{|e| e =~ /^(utm_|cm_mmc|arefid|nsctrid)/ }
    uri.scheme + "://" + uri.host + uri.path + (params.empty? ? "" : "?" + params.to_query)
  end
end
