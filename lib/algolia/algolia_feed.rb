# -*- encoding : utf-8 -*-

require 'rubygems'
require 'algoliasearch'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'filemagic'
require 'zip/zip'
require 'net/http/digest_auth'

module AlgoliaFeed

  class InvalidFile < IOError; end
  class InvalidRecord < ScriptError; end
  class RejectedRecord < ScriptError; end

# TODO: Missing categories for Amazon

  class AlgoliaFeed

    attr_accessor :records, :urls, :conversions, :product_field, :batch_size, :index_name, :prod_index_name, :index, :tmpdir, :forbidden_cats, :forbidden_names, :debug, :merchant_cache, :category_fields, :http_auth

    def self.run(params={})
      self.new(params).run
    end

    def self.make_production(params={})
      self.new(params).make_production
    end

    def initialize(params={})
      self.urls            = params[:urls]            || []
      self.conversions     = params[:conversions]     || {}
      self.product_field   = params[:product_field]   || 'product'
      self.batch_size      = params[:batch_size]      || 1000
      self.index_name      = params[:index_name]      || 'products-feed-fr-new'
      self.prod_index_name = params[:prod_index_name] || 'products-feed-fr'
      self.tmpdir          = params[:tmpdir]          || '/home/shopelia/shopelia/tmp/algolia'
      self.forbidden_cats  = params[:forbidden_cats]  || ['sextoys', 'erotique']
      self.forbidden_names = params[:forbidden_names] || ['godemich', '\bgode\b', 'cockring', 'rosebud', '\bplug anal\b', 'vibromasseur', 'sextoy', 'masturbat' ]
      self.debug           = params[:debug]           || 0
      self.category_fields = params[:category_fields] || []   
      self.merchant_cache  = {}
      self.http_auth = params[:http_auth] || {}
    end

    def connect(index_name)
      self.index = Algolia::Index.new(index_name)
    end

    def make_production
      Algolia.move_index(self.index_name, self.prod_index_name)
      index = Algolia::Index.new(self.prod_index_name)
      index.set_settings({"attributesToIndex" => ['name', 'brand', 'reference']})
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
            puts "Found XML: #{r.outer_xml}" if self.debug > 2
            product = product_hash(r.outer_xml)
            puts "Got product hash: #{product.inspect}" if self.debug > 2
            record = process_product(product)
            puts "Got record: #{record}" if self.debug > 2
            check_forbidden(record)
            products_counter += 1
            self.records << record
          rescue RejectedRecord => e
            puts "Rejecting record: #{e}\n#{e.backtrace.join("\n")}\nRecord: #{record.inspect}" if self.debug > 2
            next
          rescue InvalidRecord => e
            puts "Failed to add record: #{e.backtrace.join("\n")}\nRecord: #{record.inspect}" if self.debug > 1
            next
          end
          self.send_batch if self.records.size >= self.batch_size
        end
        self.send_batch
        puts "[#{Time.now}] #{decoded_file} - Processed #{products_counter} products in #{Time.now - file_start} seconds (#{(products_counter.to_f/(Time.now - file_start)).round} pr/s)" if self.debug > 0
      end  
    end

    def check_forbidden(record)
      forbidden_categories = "(#{self.forbidden_cats.join('|')})"
      record['_tags'].each do |tag|
        next unless tag=~/category:/
        xtag = tag.downcase.gsub(/category:/, '').gsub(/[^a-z]/, '')
        raise RejectedRecord," Record belongs to category #{xtag}" if xtag =~ /#{forbidden_categories}/
      end
      forbidden_names = "(#{self.forbidden_names.join('|')})"
      raise RejectedRecord, "Record has forbidden name #{record['name']}" if record['name'] =~ /#{forbidden_names}/
      raise RejectedRecord, "Record has no product URL" unless (record.has_key?('product_url') and record['product_url'] =~ /\Ahttp/)
      raise RejectedRecord, "Record has no price" unless (record.has_key?('price') and record['price'] > 0)
      raise RejectedRecord, "Record has no usable image #{record['image_url']}" unless (record.has_key?('image_url') and record['image_url'] =~ /\Ahttp/)
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
      self.index.add_objects(self.records)
      self.records = []
    end

    def old_retrieve_url(url)
      raw_file = "#{self.tmpdir}/#{self.class}-#{Time.now.to_i}.raw"
      output = `wget -O #{raw_file} #{url}` if self.debug > 0
      raise InvalidFile, "Cannot download #{url}: #{output}" unless File.exist?(raw_file)
      return raw_file
    end

    def retrieve_url(url)
      raw_file = "#{self.tmpdir}/#{self.class}-#{Time.now.to_i}.raw"
      puts "Downloading URL #{url}" if self.debug > 0
      if url =~ /^http/
        digest_auth = Net::HTTP::DigestAuth.new
        uri = URI.parse url
        if self.http_auth.has_key?(:user)
          uri.user = self.http_auth[:user]
          uri.password = self.http_auth[:password]
        end

        h = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https')
        req = Net::HTTP::Get.new uri.request_uri
        res = h.request req
  
        if res.code == '401'
          auth = digest_auth.auth_header uri, res['www-authenticate'], 'GET'
          req = Net::HTTP::Get.new uri.request_uri
          req.add_field 'Authorization', auth
          res = h.request req
        end

        if res.code == '301' or res.code == '302'
          puts "Redirecting to #{res.response['Location']}" if debug > 1
          return retrieve_url(res.response['Location'])
        end

        if res.is_a?(Net::HTTPSuccess)
          puts "Writing file #{raw_file}" if debug > 1
          File.open(raw_file, 'wb') do |f|
            f.write res.body
          end
        else
          raise InvalidFile, "Cannot download #{url}: #{res.message}"
        end
      else
        open(url) do |ftp|
          File.open(raw_file, 'wb') do |f|
            ftp.each_line do |line|
              f.write line
            end
          end
        end
      end

      raw_file
    end

    def decompress_datafile(raw_file)
      decoded_file = "#{self.tmpdir}/#{self.class}-#{Time.now.to_i}.xml"
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
        puts "product[#{from}] = #{product[from]} -> record[#{to}]" if self.debug > 2
        record[to] = product[from] if product.has_key?(from)
        record[to] = record[to].to_i if (record[to] =~ /\A[0-9.]+\Z/ and ['price', 'shipping_price', 'rank'].include?(to))
      end
      if record.has_key?('ean')
        record['ean'].split(/\D+/).each do |ean|
          record['_tags'] << "ean:#{ean}" if ean.size > 7
        end 
        record.delete('ean')
      end
      record['_tags'] << "brand:#{record['brand']}" if record.has_key?('brand')
      add_merchant_data(record)
      record['currency'] = 'EUR' unless record.has_key?('currency')
      record['timestamp'] = Time.now.to_i
      set_categories(product, record)
      record
    end

    def canonize(url)
      Linker.clean(url)
    end

    def add_merchant_data(record)
      raise InvalidRecord, "Record has nil product_url" if record['product_url'].nil?
      record['product_url'] = canonize(record['product_url'])
      raise InvalidRecord, "Record has nil product_url" if record['product_url'].nil?
      domain = Utils.extract_domain(record['product_url'])
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
      (price.to_f * 100).to_i
    end

  end
end

require_relative 'price_minister'
require_relative 'cdiscount'
require_relative 'zanox'
require_relative 'amazon'

