require 'rubygems'
require 'algoliasearch'
require 'net/http'
require 'nokogiri'
require 'digest/md5'
require 'open-uri'
require 'zipruby'

# TODO: Split categories
# TODO: Add params on object creation
# URL rewrite

module AlgoliaFeed

  class AlgoliaFeed

    attr_accessor :records, :urls, :conversions, :product_field, :batch_size, :algolia_application_id, :algolia_api_key, :algolia_index_name, :algolia_index

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

      Algolia.init :application_id => self.algolia_application_id,
                   :api_key        => self.algolia_api_key
      self.algolia_index = Algolia::Index.new(self.algolia_index_name)

    end

    def run
      self.urls.each_pair do |url, compression|
        self.records = []
        products = get_products(url, compression)
        products_count = products.size
        file_start = Time.now
        products_counter = 0
        puts "[#{Time.now}] Processing #{products_count} products"
        products.each do |product|
          products_counter += 1
          pct = 100*(products_counter.to_f/products_count)
          puts "[#{Time.now}] #{pct.round}% done" if pct.round(3) % 10 == 0
          record = process_product(product)
          self.records << record if record.present?
          if self.records.size >= self.batch_size
            self.send_batch
          end
        end
        self.send_batch
        puts "[#{Time.now}] Processed #{products_count} products in #{Time.now - file_start} seconds (#{(products_count.to_f/(Time.now - file_start)).round} pr/s)"
      end
    end

    def send_batch
      return unless self.records.size > 0
      self.algolia_index.add_objects(self.records)
      self.records = []
    end

    def get_products(url, compression)
      puts "#{Time.now} Fetching #{url}"
      raw_content = ''
      if url =~ /^http/
        uri = URI(url)
        raw_content = Net::HTTP.get(uri)
      else
        open(url) do |f|
          f.each_line do |line|
            raw_content += line
          end
        end
      end
      puts "#{Time.now} Unzipping"
      if compression == 'gz'
        gz = Zlib::GzipReader.new(StringIO.new(raw_content))
        content = gz.read
      elsif compression == 'zip'
        {}.tap do |entries|
          Zip::Archive.open_buffer(raw_content) do |archive|
            archive.each do |entry|
              content = entry.read
            end
          end
        end
      else
        content = raw_content
      end
      puts "#{Time.now} Parsing XML"
      doc = Nokogiri::XML(content)
      products = doc.xpath("//#{self.product_field}")
      puts "#{Time.now} Looping over products"
      products
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

