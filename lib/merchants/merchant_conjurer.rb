module MerchantConjurer

  def self.from_url url
    klass = Utils.extract_domain(url).gsub(".", "_").camelize
    klass.constantize.new(url)
  rescue
    nil
  end

end