module MerchantHelper

  def self.process_version url, version
    m = self.from_url(url)
    version = m.process_shipping_price(version) if m.present? && m.respond_to?('process_shipping_price')
    version = m.process_shipping_info(version) if m.present? && m.respond_to?('process_shipping_info')
    version = m.process_availability(version) if m.present? && m.respond_to?('process_availability')
    version = m.process_name(version) if m.present? && m.respond_to?('process_name')
    version = m.process_price(version) if m.present? && m.respond_to?('process_price')
    version
  end

  def self.monetize url
    self.from_url(url).monetize
  end

  def self.canonize url
    m = self.from_url(url)
    m.present? && m.respond_to?('canonize') ? m.canonize : nil
  end

  private

  def self.from_url url
    klass = Utils.extract_domain(url).gsub(/[\.-]/, "_").camelize
    klass.constantize.new(url)
  rescue
    nil
  end
end