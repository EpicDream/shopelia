# -*- encoding : utf-8 -*-

require 'rubygems'
require 'algoliasearch'
require 'net/http'
require 'nokogiri'
require 'digest/md5'
require 'open-uri'
require 'filemagic'
require 'zip/zip'

module AlgoliaFeed

  class InvalidFile < IOError; end
  class InvalidRecord < ScriptError; end

  class AlgoliaFeed

    attr_accessor :records, :urls, :conversions, :product_field, :batch_size, :index_name, :index, :tmpdir, :forbidden, :debug, :merchant_cache

    def self.run(params={})
      self.new(params).run
    end

    def self.make_production(params={})
      self.new(params).make_production
    end

    def initialize(params={})
      self.urls                  = params[:urls]                  || []
      self.conversions           = params[:conversions]           || {}
      self.product_field         = params[:product_field]         || 'product'
      self.batch_size            = params[:batch_size]            || 1000
      self.index_name            = params[:index_name]            || 'products-feed-fr'
      self.tmpdir                = params[:tmpdir]                || '/tmp'
      self.forbidden             = params[:forbidden]             || ['sextoys', 'erotique']
      self.debug                 = params[:debug]                 || false
      self.merchant_cache = {}
    end

    def connect(index_name)
      self.index = Algolia::Index.new(index_name)
    end

    def run
      connect(self.index_name)

      self.urls.each do |url|
        begin
          raw_file = retrieve_url(url)
          decoded_file = decompress_datafile(raw_file)
          File.unlink(raw_file)
          process_xml(decoded_file)
          File.unlink(decoded_file)
        rescue InvalidFile => e
          puts "Failed to parse file #{url} : #{e.backtrace.join("\n")}"
          next
        end
      end
    end

    def process_xml(decoded_file)  
      self.records = []
      file_start = Time.now
      products_counter = 0
      File.open(decoded_file, 'rb') do |f|
        reader = Nokogiri::XML::Reader(f) { |config| config.nonet.noblanks }
        reader.each do |r|
          begin
            next unless r.name == self.product_field && r.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
            product = product_hash(r.outer_xml)
            record = process_product(product)
            check_forbidden(record)
            products_counter += 1
            self.records << record
          rescue InvalidRecord => e
            puts "Failed to add record: #{e}" if self.debug
            next
          end
          self.send_batch if self.records.size >= self.batch_size
        end
        self.send_batch
        puts "[#{Time.now}] #{decoded_file} - Processed #{products_counter} products in #{Time.now - file_start} seconds (#{(products_counter.to_f/(Time.now - file_start)).round} pr/s)" if self.debug
      end  
    end

    def check_forbidden(record)
      forbidden_tags = "(#{self.forbidden.join('|')})"
      record['_tags'].each do |tag|
        next unless tag=~/category:/
        xtag = tag.downcase.gsub(/category:/, '').gsub(/[^a-z]/, '')
        raise InvalidRecord," Record belongs to category #{xtag}" if xtag =~ /#{forbidden_tags}/
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

    def send_batch
      return unless self.records.size > 0
      self.index.save_objects(self.records)
      self.records = []
    end

    def retrieve_url(url)
      raw_file = "#{self.tmpdir}/algolia_feed_raw_data-#{Time.now.to_i}"
      File.open(raw_file, 'wb') do |f|
        if url =~ /^http/
          uri = URI(url)
          res = Net::HTTP.get_response(uri)
          if res.is_a?(Net::HTTPSuccess)
            f.write res.body
          else
            raise InvalidFile, "Cannot download #{url}: #{res.message}"
          end
        else
          open(url) do |ftp|
            ftp.each_line do |line|
              f.write line
            end
          end
        end
      end
      raw_file
    end

    def decompress_datafile(raw_file)
      decoded_file = "#{self.tmpdir}/algolia_feed_decoded_data-#{Time.now.to_i}"
      file_type = FileMagic.new.file(raw_file)
      if file_type =~ /^gzip compressed data/
        File.open(decoded_file, 'wb') do |f|
          Zlib::GzipReader.open(raw_file) do |gz|
            f.write gz.read
          end
        end
      elsif file_type =~ /^Zip archive data/
        Zip::ZipFile.open(raw_file) do |zipfile|
          zipfile.each do |file|
            zipfile.extract(file, decoded_file)
          end
        end
      else
        FileUtils.copy_file(raw_file, decoded_file)
      end
      decoded_file
    end

    def process_product(product)
      record = {'_tags' => []}
      self.conversions.each_pair do |from, to|
        record[to] = product[from] if product.has_key?(from)
      end
      if record.has_key?('ean')
        record['ean'].split(/\D+/).each do |ean|
        record['_tags'] << "ean:#{ean}" if ean.size > 7
        end 
        record.delete('ean')
      end
      if record.has_key?('brand')
        record['_tags'] << "brand:#{record['brand']}" if record.has_key?('brand')
      end
      add_merchant_data(record)
      record['timestamp'] = Time.now.to_i
      record
    end

    def canonize_url(url)
      url
    end

    def add_merchant_data(record)
      record['product_url'] = canonize_url(record['product_url'])
      record['objectID'] =  Digest::MD5.hexdigest(record['product_url'])
      uri = URI(record['product_url'])
      domain_elements = uri.host.split(/\./)
      while domain_elements.size > 2
        domain_elements.shift
      end
      domain = domain_elements.join('.')
      unless self.merchant_cache.has_key?(domain)
        merchant = Merchant.find_by_domain(domain)
        if merchant.present?
          self.merchant_cache[domain] = {
            :name   => merchant.name,
            :data   => MerchantSerializer.new(merchant).as_json[:merchant],
            :saturn => merchant.viking_data.present? ? '1' : '0'
          }
        else
          self.merchant_cache[domain] = {}
        end
      end
      return unless self.merchant_cache[domain].has_key?(:name)
      record['merchant'] = self.merchant_cache[domain][:data]
      record['_tags'] << "merchant_name:#{self.merchant_cache[domain][:name]}"
      record['saturn'] = self.merchant_cache[domain][:saturn]
    end

    def get_categories(fields)
      categories = []
      fields.each do |field|
        next if field.nil?
        categories << field.split(/(\>|\s+\-\s+|\s+\/\s+)/)
      end
      categories.flatten
    end

  end
end

require_relative 'price_minister'
require_relative 'cdiscount'
require_relative 'zanox'

