module MerchantHelper
  UNAVAILABLE = "Indisponible"
  AVAILABLE = "En stock"

  def self.availability_hash(url)
    helper = self.get_helper(url)
    return {} if helper.nil?
    return helper::AVAILABILITY_HASH if helper.const_defined?(:AVAILABILITY_HASH)
    return {}
  end

  def self.process_version url, version
    m = self.from_url(url)
    return version unless m.present?
    version = m.process_shipping_price(version) if m.respond_to?('process_shipping_price')
    version = m.process_shipping_info(version) if m.respond_to?('process_shipping_info')
    version = m.process_availability(version) if m.respond_to?('process_availability')
    version = m.process_name(version) if m.respond_to?('process_name')
    version = m.process_price(version) if m.respond_to?('process_price')
    version
  end

  def self.monetize url
    self.from_url(url).monetize
  end

  def self.canonize url
    m = self.from_url(url)
    m.present? && m.respond_to?('canonize') ? m.canonize : nil
  end

  # Return nil if cannot find a price.
  def self.parse_float str
    str = str.downcase
    # special cases
    str = str.gsub(/^.*un total de/, "")
    str = str.gsub(/\(.*\)/, "")
    if str =~ /gratuit/ || str =~ /free/ || str =~ /offert/
      0.0
    else
      if m = str.match(/^[^\d]*(\d+)[^\d](\d\d\d) ?[^\d] ?(\d+)/)
        m[1].to_f * 1000 + m[2].to_f + m[3].to_f / 100
      elsif m = str.match(/^[^\d]*(\d+)[^\d](\d\d\d)/)
        m[1].to_f * 1000 + m[2].to_f
      elsif m = str.match(/^[^\d]*(\d+)[^\d]*$/) || m = str.match(/^[^\d]*(\d+)[^\d]{1,2}(\d+)/)
        m[1].to_f + m[2].to_f / 100
      else
        nil
      end
    end
  end


  private

  def self.get_helper url
    Utils.extract_domain(url).gsub(/[\.-]/, "_").camelize.constantize
  rescue
    nil
  end

  def self.from_url url
    klass = self.get_helper(url)
    if klass.nil?
      nil
    else
      klass.new(url)
    end
  end
end