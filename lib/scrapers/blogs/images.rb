# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class Images
      MIN_WIDTH = 300
      
      def self.extract document
        document.xpath('.//img').map(&src).compact.map do |href|
          next unless dimensions = FastImage.size(href)
          next if dimensions[0] < MIN_WIDTH
          href
        end
      end
      
      private
      
      def self.src
        Proc.new { |img| 
          src = img.attribute('src').value 
          src if src =~ /^http/
        }
      end
      
    end
  end
end