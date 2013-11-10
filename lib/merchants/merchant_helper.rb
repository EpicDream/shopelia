# -*- encoding : utf-8 -*-
module MerchantHelper
  UNAVAILABLE = "Indisponible"
  AVAILABLE = "En stock"
  FREE_PRICE = "0.00 €"

  def self.availability_hash(url)
    helper = self.get_helper(url)
    return {} if helper.nil?
    return helper::AVAILABILITY_HASH if helper.const_defined?(:AVAILABILITY_HASH)
    return {}
  end

  def self.process_version url, version
    m = self.from_url(url)
    return version unless m.present?

    # Clean up image_url
    version[:image_url] = "http:#{version[:image_url]}" if version[:image_url] =~ /\A\/\//

    # Process version
    version = m.process_shipping_price(version) if m.respond_to?('process_shipping_price')
    version = m.process_price_shipping(version) if m.respond_to?('process_price_shipping')
    version = m.process_shipping_info(version) if m.respond_to?('process_shipping_info')
    version = m.process_availability(version) if m.respond_to?('process_availability')
    version = m.process_name(version) if m.respond_to?('process_name')
    version = m.process_price(version) if m.respond_to?('process_price')
    version = m.process_price_strikeout(version) if m.respond_to?('process_price_strikeout')
    version = m.process_image_url(version) if m.respond_to?('process_image_url')
    version = m.process_images(version) if m.respond_to?('process_images')
    version = m.process_options(version) if m.respond_to?('process_options')
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
  # test encore dans product_version_test.rb pour le moment
  def self.parse_float str
    str = str.downcase
    # special cases
    str = str.gsub(/\A.*un total de/, "")
    str = str.gsub(/\(.*\)/, "") unless str =~ /\(.*(\beur\b|[$€]).*\)/i
    str = str.gsub(/\(.*?\.(?!.*?\))/, "")
    str = str.gsub(/\A.*à partir de/, "")
    if str =~ /gratuit/ || str =~ /free/ || str =~ /offer[ts]/
      0.0
    else
      # match les "1 000€90", "1.000€90", "1 000€", "1 000,80", etc
      if m = str.match(/\A\D*(\d+)\D(\d{3}) ?\D ?(\d+)/)
        m[1].to_f * 1000 + m[2].to_f + m[3].to_f / 100
      # match les "1 000", "1.000", etc
      elsif m = str.match(/\A\D*(\d+) ?\D ?(\d{3})/)
        m[1].to_f * 1000 + m[2].to_f
      # match les "80", "10.00", "10€90", "10 € 90", etc
      elsif m = str.match(/\A\D*(\d+)\D*\Z/) || m = str.match(/\A\D*(\d+) ?\D{1,2} ?(\d+)/)
        m[1].to_f + m[2].to_f / 100
      else
        nil
      end
    end
  end


  private

  def self.get_helper url
    Utils.extract_domain(url).gsub(/[\.-]/, '_').gsub(/^\d+/, '').camelize.constantize
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