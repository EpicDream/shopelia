# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class Images
      MIN_WIDTH = 300
      MIN_HEIGHT = 50
      
      def self.extract document
        document.xpath('.//img').map(&src).compact.map do |href|
          next unless dimensions = FastImage.size(href) rescue nil
          next if dimensions[0] < MIN_WIDTH || dimensions[1] < 50
          href
        end.compact
      end
      
      private
      
      def self.src
        Proc.new { |img| 
          src = img.attribute('src').value rescue nil #img without src, we dont mind
          src if src =~ /^http/
        }
      end
      
    end
  end
end