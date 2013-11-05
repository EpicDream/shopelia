# -*- encoding : utf-8 -*-

require 'rubygems'
require 'nokogiri'

module AlgoliaFeed


  class RejectedRecord < ScriptError; 
    attr_accessor :reason
    def initialize(str, reason)
      super(str)
      self.reason = reason
    end
  end

  class XmlParser

    attr_accessor :records, :conversions, :product_field, :forbidden_cats, :forbidden_names, :debug, :merchant_cache, :category_fields, :algolia, :filer

    def initialize(params={})
      self.conversions     = params[:conversions]     || {}
      self.product_field   = params[:product_field]   || 'product'
      self.forbidden_cats  = params[:forbidden_cats]  || ['sextoys', 'erotique']
      self.forbidden_names = params[:forbidden_names] || ['godemich', '\bgode\b', 'cockring', 'rosebud', '\bplug anal\b', 'vibromasseur', 'sextoy', 'masturbat' ]
      self.debug           = params[:debug]           || 0
      self.category_fields = params[:category_fields] || []   
      self.merchant_cache  = {}
      @image_size_processor = ImageSizeProcessor.new

      self.algolia = AlgoliaFeed.new(params)
      self.filer = params[:filer] || 'AlgoliaFeed::FileUtils'
      params[:parser_class] = self.class
      self.filer = self.filer.constantize.new(params)
      self
    end

    def process_xml(decoded_file)
      self.records = []
      file_start = Time.now
      stats = {
        :total          => 0,
        :accepted       => 0,
      }
      File.open(decoded_file, 'rb') do |f|
        reader = Nokogiri::XML::Reader(f) { |config| config.nonet.noblanks }
        reader.each do |r|
          begin
            next unless r.name == self.product_field && r.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
            stats[:total] += 1
            puts "Found XML: #{r.outer_xml}" if self.debug > 2
            product = product_hash(r.outer_xml)
            puts "Got product hash: #{product.inspect}" if self.debug > 2
            record = process_product(product)
            puts "Got record: #{record}" if self.debug > 2
            post_process(record)
            stats[:accepted] += 1
            self.records << record
          rescue RejectedRecord => e
            puts "Rejecting record: #{e}\n#{e}\n#{e.backtrace.join("\n")}\nRecord: #{record.inspect}" if self.debug > 2
            stats[:rejected] = 0 unless stats.has_key?(:rejected)
            stats[:rejected] += 1
            stats[e.reason] = 0 unless stats.has_key?(e.reason)
            stats[e.reason] += 1
            next
          rescue => e
            puts "Crashed record: #{e}\n#{e.backtrace.join("\n")}\nRecord: #{record.inspect}"
            stats[:crashes] = 0 unless stats.has_key?(:crashes)
            stats[:crashes] += 1
            next
          end
          if self.records.size >= self.algolia.batch_size
            self.algolia.send_batch(self.records)
            self.records = []
          end
        end
        self.algolia.send_batch(self.records)
        puts "[#{Time.now}] #{decoded_file} - Time: #{Time.now - file_start} - #{stats.inspect}" if self.debug > 0
      end  
    end

    def product_hash(xml)
      xml_product = Nokogiri::XML(xml).children.first
      product = {}
      xml_product.children.each do |c|
        product[c.name] = c.text if c.text=~/\S/
      end
      product
    end

    def process_product(product)
      record = {'_tags' => []}
      self.conversions.each_pair do |from, to|
        puts "product[#{from}] = #{product[from]} -> record[#{to}]" if self.debug > 2
        record[to] = product[from] if product.has_key?(from)
        record[to] = record[to].to_i if (record[to] =~ /\A\d+\Z/ and ['rank'].include?(to))
      end
      raise RejectedRecord.new("Record has no product URL", :rejected_url) unless (record.has_key?('product_url') and record['product_url'] =~ /\Ahttp/)
      raise RejectedRecord.new("Record has no price", :rejected_price) unless (record.has_key?('price') and record['price'].to_f > 0)
      raise RejectedRecord.new("Record has no usable image #{record['image_url']}", :rejected_img) unless (record.has_key?('image_url') and record['image_url'] =~ /\Ahttp/)
      if record.has_key?('ean')
        record['ean'].split(/\D+/).each do |ean|
          record['_tags'] << "ean:#{ean}" if ean.size > 7
        end 
        record.delete('ean')
      end
      if record.has_key?('author')
        record['brand'] = record['author']
        record.delete('author')
      end
      record['_tags'] << "brand:#{record['brand']}" if record.has_key?('brand')
      record['product_url'] = canonize(record['product_url'])
      raise RejectedRecord.new("Record has nil product_url", :rejected_url) if record['product_url'].nil?
      domain = Utils.extract_domain(record['product_url'])
      puts "Identified domain: #{domain}" if self.debug > 2
      unless self.merchant_cache.has_key?(domain)
        merchant = Merchant.find_or_create_by_domain(domain)
        self.merchant_cache[domain] = {
          :name   => merchant.name,
          :data   => MerchantSerializer.new(merchant).as_json[:merchant],
          :saturn => merchant.viking_data.present? ? '1' : '0'
        }
      end
      return unless self.merchant_cache[domain].has_key?(:name)
      record['merchant'] = self.merchant_cache[domain][:data]
      record['merchant_name'] = self.merchant_cache[domain][:name]
      record['_tags'] << "merchant_name:#{self.merchant_cache[domain][:name]}"
      record['saturn'] = self.merchant_cache[domain][:saturn]
      record['currency'] = 'EUR' unless record.has_key?('currency')
      record['timestamp'] = Time.now.to_i
      record['origin_product_url'] = record['product_url']
      set_categories(product, record)
      record
    end

    def post_process(record)
      forbidden_categories = "(#{self.forbidden_cats.join('|')})"
      record['_tags'].each do |tag|
        next unless tag=~/category:/
        xtag = tag.downcase.gsub(/category:/, '').gsub(/[^a-z]/, '')
        raise RejectedRecord.new("Record belongs to category #{xtag}", :rejected_sex) if xtag =~ /#{forbidden_categories}/
      end
      forbidden_names = "(#{self.forbidden_names.join('|')})"
      raise RejectedRecord.new("Record has forbidden name #{record['name']}", :rejected_sex) if record['name'] =~ /#{forbidden_names}/

      # Set image size
      record['image_size'] = @image_size_processor.get(record['image_url'])
      record.delete('image_size') if record['image_size'].nil?

      UrlMonetizer.new.set(record['product_url'], record['origin_product_url']) if record['product_url'] != record['origin_product_url']
      record.delete('origin_product_url')
    end

    def canonize(url)
      Linker.clean(url)
    end

    def set_categories(product, record)
      categories = []
      self.category_fields.each do |field_name|
        next unless product.has_key?(field_name)
        field = product[field_name]
        categories << field.split(/\s+(?:\-|\>|\/)\s+/)
      end
      categories.flatten.each do |c|
        record['_tags'] << "category:#{c.to_s}"
      end
      record['category'] = categories.join(' > ')
    end

    def to_cents(price)
      (price.to_f * 100).round
    end

  end
end
