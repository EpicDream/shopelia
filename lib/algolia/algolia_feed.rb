# -*- encoding : utf-8 -*-

require 'rubygems'
require 'algoliasearch'
require 'net/http'
require 'nokogiri'
require 'digest/md5'
require 'open-uri'
require 'filemagic'
require 'zip/zip'



# TODO: Split categories
# TODO: Add params on object creation
# URL rewrite

module AlgoliaFeed

  class AlgoliaFeed

    attr_accessor :records, :urls, :conversions, :product_field, :batch_size, :algolia_application_id, :algolia_api_key, :algolia_index_name, :algolia_index, :tmpdir, :current_file

    def self.run
      self.new.run
    end

    def initialize
      self.urls = {}
      self.conversions = []
      self.product_field = 'product'
      self.batch_size = 1000
      self.algolia_index_name = 'products-feed-fr-new'
      self.algolia_application_id = "JUFLKNI0PS"
      self.algolia_api_key = "bd7e7d322cf11e241e3a8fb22aeb5620"
      self.tmpdir = '/var/lib/db/algolia'

      Algolia.init :application_id => self.algolia_application_id,
                   :api_key        => self.algolia_api_key
      self.algolia_index = Algolia::Index.new(self.algolia_index_name)

    end

    def run
      self.urls.each do |url|
        self.records = []
        reader = get_products_reader(url)
        file_start = Time.now
        products_counter = 0
        puts "[#{Time.now}] Processing products"
        reader.each do |r|
          next unless r.name == self.product_field && r.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
          product = Nokogiri::XML(r.outer_xml).children.first
          products_counter += 1
          puts "#{Time.now} Done #{products_counter} products" if products_counter % 10000 == 0 
          record = process_product(product)
          self.records << record if record.present?
          if self.records.size >= self.batch_size
            self.send_batch
          end
        end
        self.send_batch
        puts "[#{Time.now}] Processed #{products_counter} products in #{Time.now - file_start} seconds (#{(products_counter.to_f/(Time.now - file_start)).round} pr/s)"
        reader = nil
        unlink(current_file)
      end
    end

    def send_batch
      return unless self.records.size > 0
      self.algolia_index.add_objects(self.records)
      self.records = []
    end

    def get_products_reader(url)
      puts "#{Time.now} Fetching #{url}"
      raw_file = "#{self.tmpdir}/algolia_feed_raw_data-#{Time.now}"
      decoded_file = "#{self.tmpdir}/algolia_feed_decoded_file-#{Time.now}"
      if url =~ /^http/
        File.open(raw_file, 'wb') do |f|
          uri = URI(url)
          f.write Net::HTTP.get(uri)
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
        record[to] = product.xpath(from).text if product.xpath(from).text.size > 0
      end
      if record['ean'].present?
        record['_tags'] = []
        record['ean'].split(/\D+/).each do |ean|
          record['_tags'] << "ean:#{ean}" if ean.size > 7
        end 
        record.delete('ean')
      end
      record
    end
  end
end

require_relative 'price_minister'
require_relative 'cdiscount'

