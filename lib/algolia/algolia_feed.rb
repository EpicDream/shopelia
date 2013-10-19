# -*- encoding : utf-8 -*-

require 'rubygems'
require 'algoliasearch'
require 'net/http'
require 'nokogiri'
require 'digest/md5'
require 'open-uri'
require 'filemagic'
require 'zip/zip'

# TODO: Add params on object creation
# Select search fields on index creation - name, brand, reference

module AlgoliaFeed

  class AlgoliaFeed

    attr_accessor :records, :urls, :conversions, :product_field, :batch_size, :algolia_application_id, :algolia_api_key, :algolia_index_name, :algolia_index, :algolia_production_index_name, :tmpdir, :current_file

    def self.run
      self.new.run
    end

    def self.make_production
      self.new.make_production
    end

    def initialize
      self.urls = []
      self.conversions = {}
      self.product_field = 'product'
      self.batch_size = 1000
      self.algolia_index_name = 'products-feed-fr-new'
      self.algolia_production_index_name = 'products-feed-fr'
      self.algolia_application_id = "JUFLKNI0PS"
      self.algolia_api_key = "bd7e7d322cf11e241e3a8fb22aeb5620"
      self.tmpdir = '/tmp'
    end

    def make_production
      Algolia.init :application_id => self.algolia_application_id,
                   :api_key        => self.algolia_api_key
      puts Algolia.move_index(self.algolia_index_name, self.algolia_production_index_name)
      index = Algolia::Index.new(self.algolia_production_index_name)
      index.set_settings({"attributesToIndex" => ['name', 'brand', 'reference']})
    end

    def run
      Algolia.init :application_id => self.algolia_application_id,
                   :api_key        => self.algolia_api_key
      self.algolia_index = Algolia::Index.new(self.algolia_index_name)

      self.urls.each do |url|
        self.records = []
				reader = nil
				begin
          reader = get_products_reader(url)
				rescue => e
					puts e
				  next
				end
        file_start = Time.now
        products_counter = 0
        puts "[#{Time.now}] Processing products"
        reader.each do |r|
          next unless r.name == self.product_field && r.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          xml_product = Nokogiri::XML(r.outer_xml).children.first
					product = {}
					xml_product.children.each do |c|
						product[c.name] = c.text if c.text=~/\S/
					end
          products_counter += 1
#          puts "#{Time.now} Done #{products_counter} products" if products_counter % 100000 == 0 
          record = process_product(product)
          self.records << record if record.present?
          if self.records.size >= self.batch_size
            self.send_batch
          end
        end
        self.send_batch
        puts "[#{Time.now}] Processed #{products_counter} products in #{Time.now - file_start} seconds (#{(products_counter.to_f/(Time.now - file_start)).round} pr/s)"
        reader = nil
        File.unlink(self.current_file)
      end
    end

    def send_batch
      return unless self.records.size > 0
      self.algolia_index.add_objects(self.records)
      self.records = []
    end

    def get_products_reader(url)
      puts "#{Time.now} Fetching #{url}"
      raw_file = "#{self.tmpdir}/algolia_feed_raw_data-#{Time.now.to_i}"
      decoded_file = "#{self.tmpdir}/algolia_feed_decoded_file-#{Time.now.to_i}"
      if url =~ /^http/
        File.open(raw_file, 'wb') do |f|
          uri = URI(url)
          res = Net::HTTP.get_response(uri)
					if res.is_a?(Net::HTTPSuccess)
						f.write res.body
					else
						raise StandardError, "Cannot download #{url}: #{res.message}"
					end
        end
      else
        File.open(raw_file, 'wb') do |f|
          open(url) do |http|
            http.each_line do |line|
              f.write line
            end
          end
        end
      end

      puts "#{Time.now} Unzipping"
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
      File.unlink(raw_file)

      products = []
      self.current_file = decoded_file
      f = File.open(decoded_file, 'rb')
      reader = Nokogiri::XML::Reader(f) { |config| config.nonet.noblanks }
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
      record
    end
  end
end

require_relative 'price_minister'
require_relative 'cdiscount'
require_relative 'zanox'

