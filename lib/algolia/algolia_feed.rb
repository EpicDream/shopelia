# -*- encoding : utf-8 -*-

require 'rubygems'
require 'algoliasearch'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'filemagic'
require 'zip/zip'
require 'net/http/digest_auth'
require 'find'

module AlgoliaFeed

  class InvalidFile < IOError; end
  class RejectedRecord < ScriptError; 
    attr_accessor :reason
    def initialize(str, reason)
      super(str)
      self.reason = reason
    end
  end

# TODO: Missing categories for Amazon
# TODO: multithreading
# TODO: Admin page

  class AlgoliaFeed

    attr_accessor :records, :urls, :conversions, :product_field, :batch_size, :index_name, :prod_index_name, :index, :tmpdir, :forbidden_cats, :forbidden_names, :debug, :merchant_cache, :category_fields, :http_auth, :rejected_files

    def self.make_production(params={})
      self.new(params).make_production
    end

    def self.download(params={})
      self.new(params).download
    end

    def self.process_xml_directory(params={})
      self.new(params).process_xml_directory
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
      self.rejected_files = params[:rejected_files] || []
    end

    def connect(index_name=nil)
      self.index = Algolia::Index.new(index_name || self.index_name)
    end

    def make_production
      Algolia.move_index(self.index_name, self.prod_index_name)
    end

    def set_index_attributes
      self.index.set_settings({"attributesToIndex" => ['name', 'brand', 'reference'], "customRanking" => ["asc(rank)"]})
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
            check_forbidden(record)
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
          self.send_batch if self.records.size >= self.batch_size
        end
        self.send_batch
        puts "[#{Time.now}] #{decoded_file} - Time: #{Time.now - file_start} - #{stats.inspect}" if self.debug > 0
      end  
    end

    def check_forbidden(record)
      forbidden_categories = "(#{self.forbidden_cats.join('|')})"
      record['_tags'].each do |tag|
        next unless tag=~/category:/
        xtag = tag.downcase.gsub(/category:/, '').gsub(/[^a-z]/, '')
        raise RejectedRecord.new("Record belongs to category #{xtag}", :rejected_sex) if xtag =~ /#{forbidden_categories}/
      end
      forbidden_names = "(#{self.forbidden_names.join('|')})"
      raise RejectedRecord.new("Record has forbidden name #{record['name']}", :rejected_sex) if record['name'] =~ /#{forbidden_names}/
      raise RejectedRecord.new("Record has no product URL", :rejected_url) unless (record.has_key?('product_url') and record['product_url'] =~ /\Ahttp/)
      raise RejectedRecord.new("Record has no price", :rejected_price) unless (record.has_key?('price') and record['price'] > 0)
      raise RejectedRecord.new("Record has no usable image #{record['image_url']}", :rejected_img) unless (record.has_key?('image_url') and record['image_url'] =~ /\Ahttp/)
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

    def retrieve_url(url, dir = nil, raw_file=nil)
      unless raw_file.present?
        uri = URI(url)
        basename = uri.path.gsub(/\A.+\//,'').gsub(/xml.*?\Z/, 'xml')
        basename = "#{basename}.xml" unless basename =~ /\.xml\Z/
        raw_file = "#{dir}/#{basename}.raw"
      end
      dir = "#{self.tmpdir}/#{self.class}" unless dir.present?
      Dir.mkdir(dir) unless Dir.exists?(dir)
      raw_file = "#{dir}/#{raw_file}"
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

    def decompress_datafile(raw_file, dir=nil, decoded_file=nil)
      dir = "#{self.tmpdir}/#{self.class}" unless dir.present?
      Dir.mkdir(dir) unless Dir.exists?(dir)
      if decoded_file.present?
        decoded_file = "#{dir}/#{decoded_file}" 
      else
        decoded_file = raw_file.gsub(/\.raw\Z/, '')
      end
      file_type = FileMagic.new.file(raw_file)
      if file_type =~ /^gzip compressed data/
        File.open(decoded_file, 'wb') do |f|
          puts "Extracting #{decoded_file}" if debug > 1
          Zlib::GzipReader.open(raw_file) do |gz|
            f.write gz.read
          end
        end
      elsif file_type =~ /^Zip archive data/
        Zip::ZipFile.open(raw_file) do |zipfile|
          if zipfile.count > 1
            zipfile.each do |file|
              next if self.rejected_files.include?(file.to_s)
              puts "Extracting #{dir}/#{file}" if debug > 1
              zipfile.extract(file, "#{dir}/#{file}")
            end
          else
            file = zipfile.first
              puts "Extracting #{decoded_file}" if debug > 1
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
        record[to] = record[to].to_i if (record[to] =~ /\A\d+\Z/ and ['rank'].include?(to))
      end
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
      raise RejectedRecord.new("Record has nil product_url", :rejected_url) if record['product_url'].nil?
      record['product_url'] = canonize(record['product_url'])
      raise RejectedRecord.new("Record has nil product_url", :rejected_url) if record['product_url'].nil?
      domain = Utils.extract_domain(record['product_url'])
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

    def download
      self.urls.each do |url|
        begin
          raw_file = retrieve_url(url)
          decoded_file = decompress_datafile(raw_file)
          File.unlink(raw_file)
        rescue => e
          puts "Failed to download URL #{url} : #{e}\n#{e.backtrace.join("\n")}"
          next
        end
      end
    end

    def process_xml_directory(dir=nil, free_children=6)
      self.connect(self.index_name)
      self.set_index_attributes
      dir = self.tmpdir unless dir.present?
      trap('CLD') {
        free_children += 1
      }
      Find.find(dir) do |path|
        next unless File.file?(path)
        while (free_children < 1)
          sleep 1
        end
        free_children -= 1
        fork do
					ActiveRecord::Base.establish_connection
          class_name = path.split(/\//)[-2]
          worker = class_name.constantize.new(debug: self.debug)
          worker.connect
          worker.process_xml(path)
					exit
        end
      end
      Process.waitall
    end

  end
end

require_relative 'price_minister'
require_relative 'tradedoubler'
require_relative 'zanox'
require_relative 'amazon'

