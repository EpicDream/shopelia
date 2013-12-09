# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class Content
      
      def self.extract document
        content = document.search(".entry-content, .texty").first || document
        content.xpath(".//script").map(&:remove) 
        texts = content.xpath(".//div/text()[normalize-space()] | .//p/text()[normalize-space()] | .//text()[normalize-space()]").map(&:text)
        texts = texts.delete_if { |text| text =~ /CDATA/}
        texts.join("\n")
      end
      
    end
  end
end