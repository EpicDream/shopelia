# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class Images
      
      def self.extract document
        document.xpath('.//img').map(&src).compact
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