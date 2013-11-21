# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class Description
      
      def self.extract document
        document.xpath(".//text()[normalize-space()]").text.strip
      end
      
    end
  end
end