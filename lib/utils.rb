class Utils

  def self.extract_domain url
    if url.match(/tradedoubler/)
      url = URI.unescape(url.gsub(/^.*url\((.*)\).*$/, '\1'))
    elsif url.match(/zanox/)
      url = URI.unescape(url.gsub(/^.*\[\[(.*)\]\].*$/, "http://\\1"))
    elsif url.match(/effiliation/)
      url = url.gsub(/http\:\/\/track.effiliation.com\/servlet\/effi.redir\?id_compteur=\d+&url\=/, "")
    end
    host = self.parse_uri_safely(url).host
    host.gsub(/^(?:\w+:\/\/)?[^:?#\/\s]*?([^.\s]+\.(?:[a-z]{2,}|co\.uk|org\.uk|ac\.uk|org\.au|com\.au))(?:[:?#\/]|$)/, '\1')
  end

  def self.parse_uri_safely url
    URI.parse(url.unaccent.scan(/([!\#$&-;=?-\[\]_a-z~]|%[0-9a-fA-F]{2})/).join)
  end

  def self.strip_tracking_params url
    uri = self.parse_uri_safely(url)
    params = Rack::Utils.parse_nested_query(uri.query).delete_if{|e| e =~ /^utm_/ || e=~ /^cm_mmc/ }
    uri.scheme + "://" + uri.host + uri.path + (params.empty? ? "" : "?" + params.to_query)
  end
end