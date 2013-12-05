# -*- encoding : utf-8 -*-
class MerchantHelper
  UNAVAILABLE = "Indisponible"
  AVAILABLE = "En stock"
  FREE_PRICE = "0.00 €"

  GLOBAL_AVAILABILITY = "#{Rails.root}/lib/config/availability.yml"

  def self.monetize url
    self.from_url(url).try(:monetize) || UrlMonetizer.new.get(url)
  end

  def self.canonize url
    m = self.from_url(url)
    m.present? && m.respond_to?('canonize') ? m.canonize : nil
  end

  def self.process_version url, version
    m = self.from_url(url)
    return version unless m.present?

    return m.process version if m.kind_of? MerchantHelper

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
    version = m.process_description(version) if m.respond_to?('process_description')
    version
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

  def self.parse_rating str
    if str =~ /^\d([,\.]\d)?$/
      $~[0].to_f
    elsif str =~ %r{(\d(?:[,\.]\d)?) ?/ ?\d}
      $~[1].to_f
    elsif str =~ /^(\d[,\.]\d) .toiles sur 5/ # Amazon
      $~[1].to_f
    else
      nil
    end
  end

  def self.parse_availability str, url=nil
    helper = self.get_helper(url)
    if helper.nil? || ! (helper < MerchantHelper) # inhertits
      m = MerchantHelper.new(url)
      avails = helper && helper.const_defined?(:AVAILABILITY_HASH) ? helper::AVAILABILITY_HASH : {}
      m.availabilities = avails
    else
      m = helper.new(url)
    end
    m.parse_availability str
  end

  def self.is_aggregator? url
    url =~ /(lengow\.com|jvweb|nonstoppartner\.net|marinsm\.com)/
  end

  private

    def self.get_helper url
      Utils.extract_domain(url).gsub(/[\.-]/, '_').gsub(/^\d+/, '').camelize.constantize rescue nil
    end

    def self.from_url url
      klass = self.get_helper(url)
      if klass.nil?
        nil
      else
        klass.new(url)
      end
    end

  public

  DEFAULT_CONFIG = {
    setAvailableIfEmpty: false,
    setUnavailableIfEmpty: false,

    setDefaultPriceShippingIfEmpty: false,
    setDefaultPriceShippingAlways: false,

    setDefaultShippingInfoIfEmpty: false,
    setDefaultShippingInfoAlways: false,
    addDefaultShippingInfoBefore: false,
    addDefaultShippingInfoAfter: false,

    subImageUrlOnly: false,
    subImagesOnly: false,

    searchBackgroundImageOrColorForOptions: nil, # ou 1 ou [1,2]
  }

  attr_accessor :default_price_shipping, :default_shipping_info, :free_shipping_limit, :image_sub, :availabilities

  attr_accessor :url, :config

  def initialize(url=nil)
    @url = url
    @config = DEFAULT_CONFIG.dup
    @availabilities = {}
  end

  def canonize
    @url
  end

  def parse_availability str
    a = str.unaccent.downcase
    key = @availabilities.keys.detect { |key| key if a =~ /#{key}/i }
    return {avail: @availabilities[key], key: key, specific: true} if ! key.nil?
    dic = YAML.load(File.open(GLOBAL_AVAILABILITY))
    key = dic.keys.detect { |key| key if a =~ /#{key}/i }
    {avail: dic[key], key: key, specific: false}
  end

  def process version
    # Clean up image_url
    version[:image_url] = "http:#{version[:image_url]}" if version[:image_url] =~ /\A\/\//

    # Process version
    process_availability(version)
    process_name(version)
    process_price(version)
    process_price_shipping(version)
    process_shipping_info(version)
    process_price_strikeout(version)
    process_image_url(version)
    process_images(version)
    process_options(version)
    process_description(version)

    version
  end

  #
  def process_availability version
    return version unless version[:availability_text].blank?
    version[:availability_text] = UNAVAILABLE if @config[:setUnavailableIfEmpty]
    # AVAILABLE is prio to UNAVAILABLE if both setAvailableIfEmpty and setUnavailableIfEmpty are true
    version[:availability_text] = AVAILABLE if @config[:setAvailableIfEmpty]
    version
  end

  #
  def process_name version
    version
  end

  #
  def process_price version
    version
  end

  #
  def process_price_shipping version
    if @config[:setDefaultPriceShippingAlways] || (@config[:setDefaultPriceShippingIfEmpty] && version[:price_shipping_text].blank?)
      version[:price_shipping_text] = @default_price_shipping
    end

    if @free_shipping_limit.kind_of?(Numeric) && version[:price_text].present?
      current_price_shipping = MerchantHelper.parse_float version[:price_text]
      version[:price_shipping_text] = FREE_PRICE if ! current_price_shipping.nil? && current_price_shipping >= @free_shipping_limit
    end
    version
  end

  #
  def process_shipping_info version
    if @config[:setDefaultShippingInfoAlways] || (@config[:setDefaultShippingInfoIfEmpty] && version[:shipping_info].blank?)
      version[:shipping_info] = @default_shipping_info
      return version
    end
    version[:shipping_info] = @default_shipping_info + version[:shipping_info].to_s if @config[:addDefaultShippingInfoBefore]
    version[:shipping_info] += @default_shipping_info if @config[:addDefaultShippingInfoAfter]
    version
  end

  #
  def process_price_strikeout version
    version
  end

  #
  def process_image_url version
    version[:image_url] = version[:image_url].sub(*@image_sub) if @image_sub && version[:image_url] && ! @config[:subImagesOnly]
    version
  end

  #
  def process_images version
    return version unless version[:images].present? && @image_sub && ! @config[:subImageUrlOnly]
    version[:images] = version[:images].map do |url|
      url.sub(*@image_sub)
    end
    version
  end

  #
  def process_options version
    return version unless @config[:searchBackgroundImageOrColorForOptions]
    options = @config[:searchBackgroundImageOrColorForOptions]
    options = [options] if ! options.kind_of?(Array)
    options.each do |nb|
      option = "option#{nb}".to_sym
      if version[option].present? && version[option]["text"].blank? &&
          version[option]["src"].blank? && version[option]["style"].present?
        version[option]["style"] =~ /background(?:-color)? *: *(#?\w+) *;/i
        version[option]["text"] = $~[1] if $~
        version[option]["style"] =~ /background(?:-image)? *: *url\(([^\)]+)\) ?/i
        version[option]["src"] = $~[1] if $~
      end
    end
    version
  end

  #
  def process_description version
    version
  end

end
