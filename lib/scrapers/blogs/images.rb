# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class Images
      MIN_WIDTH = 300
      MIN_HEIGHT = 50
      
      def self.extract document, base_url
        document.xpath('.//img').map(&src(base_url)).compact.map do |href|
          next unless dimensions = FastImage.size(href) rescue nil
          next if dimensions[0] < MIN_WIDTH || dimensions[1] < 50
          href
        end.compact
      end
      
      private
      
      def self.src(base_url)
        Proc.new { |img|
          src = img.attribute('src').value rescue nil #img without src, we dont mind
          if src =~ /^http/
            src
          else
            base_url + src if src
          end
        }
      end
      
    end
  end
end