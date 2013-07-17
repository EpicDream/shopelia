class Utils

  def self.extract_domain url
    if url.match(/tradedoubler/)
      url = URI.unescape(url.gsub(/^.*url\((.*)\).*$/, '\1'))
    elsif url.match(/zanox/)
      url = URI.unescape(url.gsub(/^.*\[\[(.*)\]\].*$/, "http://\\1"))
    elsif url.match(/effiliation/)
      url = url.gsub(/http\:\/\/track.effiliation.com\/servlet\/effi.redir\?id_compteur=\d+&url\=/, "")
    end
    host = URI.parse(url.gsub(/[^0-9a-z\-\.\/\:]/, "")).host
    host.gsub(/^(?:\w+:\/\/)?[^:?#\/\s]*?([^.\s]+\.(?:[a-z]{2,}|co\.uk|org\.uk|ac\.uk|org\.au|com\.au))(?:[:?#\/]|$)/, '\1')
  end

end

