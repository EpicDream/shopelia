# -*- encoding : utf-8 -*-

require 'rubygems'
require 'algoliasearch'
require 'net/http'
require 'nokogiri'
require 'digest/md5'
require 'open-uri'
require 'filemagic'
require 'zip/zip'

# TODO: Use MerchantHelper for URL canonization
# TODO: Better use of exceptions
# TODO: cache merchant info

module AlgoliaFeed

  class AlgoliaFeed

    attr_accessor :records, :urls, :conversions, :product_field, :batch_size, :algolia_application_id, :algolia_api_key, :algolia_index_name, :algolia_index, :algolia_production_index_name, :tmpdir, :forbidden

    def self.run(params={})
      self.new(params).run
    end

    def self.make_production(params={})
      self.new(params).make_production
    end

    def initialize(params={})
      self.urls                          = params[:urls]                          || []
      self.conversions                   = params[:conversions]                   || {}
      self.product_field                 = params[:product_field]                 || 'product'
      self.batch_size                    = params[:batch_size]                    || 1000
      self.algolia_index_name            = params[:algolia_index_name]            || 'products-feed-fr-new'
      self.algolia_production_index_name = params[:algolia_production_index_name] || 'products-feed-fr'
      self.algolia_application_id        = params[:algolia_application_id]        || "JUFLKNI0PS"
      self.algolia_api_key               = params[:algolia_api_key]               || "bd7e7d322cf11e241e3a8fb22aeb5620"
      self.tmpdir                        = params[:tmpdir]                        || '/tmp'
      self.forbidden                     = params[:forbidden]                     || ['sextoys', 'erotique']
    end

    def connect(index_name)
      Algolia.init :application_id => self.algolia_application_id,
                   :api_key        => self.algolia_api_key
      index = Algolia::Index.new(index_name)
    end

    def make_production
      index = connect(self.algolia_production_index_name)
      puts Algolia.move_index(self.algolia_index_name, self.algolia_production_index_name)
      index.set_settings({"attributesToIndex" => ['name', 'brand', 'reference']})
    end

    def run
      self.algolia_index = connect(self.algolia_index_name)

      self.urls.each do |url|
        begin
          raw_file = retrieve_url(url)
          decoded_file = decompress_datafile(raw_file)
          File.unlink(raw_file)
          process_xml(decoded_file)
          File.unlink(decoded_file)
        rescue => e
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
          next unless r.name == self.product_field && r.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          products_counter += 1
          product = product_hash(r.outer_xml)
          record = process_product(product)
          record = check_forbidden(record)
          if record.present?
            self.records << record
            products_counter += 1
          end
          self.send_batch if self.records.size >= self.batch_size
        end
        self.send_batch
        puts "[#{Time.now}] #{decoded_file} - Processed #{products_counter} products in #{Time.now - file_start} seconds (#{(products_counter.to_f/(Time.now - file_start)).round} pr/s)"
      end  
    end

    def check_forbidden(record)
      return unless record.present?
      forbidden_tags = "(#{self.forbidden.join('|')})"
      record['_tags'].each do |tag|
        next unless tag=~/category:/
        xtag = tag.downcase.gsub(/category:/, '').gsub(/[^a-z]/, '')
        return if xtag =~ /#{forbidden_tags}/
      end
      record
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
      self.algolia_index.add_objects(self.records)
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
            raise StandardError, "Cannot download #{url}: #{res.message}"
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
      record = {}
      self.conversions.each_pair do |from, to|
        record[to] = product[from] if product.has_key?(from)
      end
      if record.has_key?('ean')
        record['_tags'] = []  unless record.has_key?('_tags')
        record['ean'].split(/\D+/).each do |ean|
        record['_tags'] << "ean:#{ean}" if ean.size > 7
        end 
        record.delete('ean')
      end
      if record.has_key?('brand')
        record['_tags'] = []  unless record.has_key?('_tags')
        record['_tags'] << "brand:#{record['brand']}" if record.has_key?('brand')
      end
      add_merchant_data(record)
      record
    end

    def canonize_url(url)
      url
    end

    def add_merchant_data(record)
      record['product_url'] = canonize_url(record['product_url'])
      uri = URI(record['product_url'])
      domain_elements = uri.host.split(/\./)
      
      while domain_elements.size > 2
        domain_elements.shift
      end
      merchant = Merchant.find_by_domain(domain_elements.join('.'))
      return unless merchant.present?
      record['merchant'] = MerchantSerializer.new(merchant).as_json[:merchant]
      record['_tags'] == [] unless record.has_key?('_tags')
      record['_tags'] << "merchant_name:#{merchant.name}"
      record['saturn'] =  merchant.viking_data.present? ? '1' : '0'
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

