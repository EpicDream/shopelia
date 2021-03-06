# -*- encoding : utf-8 -*-

require 'rubygems'
require 'net/http'
require 'open-uri'
require 'filemagic'
require 'zip/zip'
require 'net/http/digest_auth'
require 'find'

module AlgoliaFeed

  class InvalidFile < IOError; end

  class Filer

    attr_accessor :urls, :tmpdir, :debug, :http_auth, :rejected_files, :parser_class, :params, :clean_xml

    def self.download(params={})
      self.new(params).download
    end

    def self.process_xml_directory(params={})
      self.new(params).process_xml_directory
    end

    def initialize(params={})
      self.params         = params
      self.urls           = params[:urls]           || []
      self.tmpdir         = params[:tmpdir]         || '/home/shopelia/shopelia/tmp/algolia'
      self.debug          = params[:debug]          || 0
      self.http_auth      = params[:http_auth]      || {}
      self.rejected_files = params[:rejected_files] || []
      self.parser_class   = params[:parser_class]   || 'AlgoliaFeed::XmlParser'
      self.clean_xml      = params[:clean_xml]      || true
      self
    end

    def retrieve_url(url, dir_o=nil, raw_file_o=nil)
      dir = dir_o
      raw_file = raw_file_o
      unless raw_file.present?
        uri = URI(url)
        basename = uri.path.gsub(/\A.+\//,'').gsub(/xml.*?\Z/, 'xml')
        basename = "#{basename}.xml" unless basename =~ /\.xml\Z/
        raw_file = "#{basename}.raw"
      end
      dir = "#{self.tmpdir}/#{self.parser_class}" unless dir.present?
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
        h.read_timeout = 600
        h.continue_timeout = 600
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
          return retrieve_url(res.response['Location'], dir_o, raw_file_o)
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
      dir = "#{self.tmpdir}/#{self.parser_class}" unless dir.present?
      Dir.mkdir(dir) unless Dir.exists?(dir)
      if decoded_file.present?
        decoded_file = "#{dir}/#{decoded_file}"
      else
        decoded_file = raw_file.gsub(/\.raw\Z/, '')
      end
      while File.exists?(decoded_file)
        if m = /\-(\d+)\.xml\Z/.match(decoded_file)
          x = m[1].to_i + 1
          decoded_file.gsub!(/\-\d+\.xml\Z/, "-#{x}.xml")
        else
          decoded_file.gsub!(/\.xml\Z/, '-1.xml')
        end
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
      xmllint(decoded_file) if self.clean_xml
      decoded_file
    end

    def xmllint(path)
      xmllint = `/usr/bin/xmllint --format --output #{path} --encode UTF-8 --nocdata --nonet --recover #{path}`
      puts "xmllint failed for #{path}: #{xmllint}" if xmllint =~ /\S/
      path
    end

    def download_url(url)
      decoded_file = nil
      begin
        raw_file = retrieve_url(url)
        decoded_file = decompress_datafile(raw_file)
        File.unlink(raw_file)
      rescue => e
        puts "Failed to download URL #{url} : #{e}\n#{e.backtrace.join("\n")}"
        return
      end
      decoded_file
    end

    def download(urls=[])
      urls = self.urls if urls.size == 0
      urls.each do |url|
        self.download_url(url)
      end
    end

    def count_children(pid)
      begin
        return Sys::ProcTable.ps.select{ |p| p.ppid == pid && p.state != 'Z'}.size
      rescue => e
        puts "ps failed: #{e}" if self.debug > 1
        return nil
      end
    end

    def process_xml_directory(dir=nil, max_children=6)
      algolia = AlgoliaFeed.new(self.params)
      algolia.connect(algolia.index_name)
      algolia.set_index_attributes
      dir = self.tmpdir unless dir.present?
      Find.find(dir) do |path|
        next unless File.file?(path)
        while true
          children_count = count_children($$)
          break if children_count.is_a?(Integer) && children_count < max_children
          sleep 1
        end
        fork do
          $0 = "Feed worker #{path}"
          ActiveRecord::Base.establish_connection
          class_name = path.split(/\//)[-2]
          worker = class_name.constantize.new(self.params)
          worker.algolia.connect
          begin
            worker.process_xml(path)
          rescue => e
            puts "Parsing of #{path} failed: #{e}\n#{e.backtrace.join("\n")}"
          end
          exit
        end
      end
      Process.waitall
    end

  end
end

