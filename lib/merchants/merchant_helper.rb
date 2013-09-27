module MerchantHelper

  def self.process_version url, version
    m = self.from_url(url)
    version = m.process_shipping_price(version) if m.present? && m.respond_to?('process_shipping_price') && version[:price_shipping_text].present?
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
    klass = Utils.extract_domain(url).gsub(".", "_").camelize
    klass.constantize.new(url)
  rescue
    nil
  end
end