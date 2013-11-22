# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class ProductsFinder
      
      def initialize html, url
        @html = html
        @url = url
        @uri = URI(url)
        @blocks = blocks()
      end
      
      def products
        @blocks.map do |block|
          links(block)
        end.flatten
      end
      
      def blocks
        content = @html.search(".entry-content").first || @html
        content.search(".//div | .//p")
      end
      
      private
      
      def links block
        links = block.xpath(".//a").map(&href).compact
        links.delete_if { |link| 
          URI(link).host == URI(@url).host
        }  
      end
      
      def may_include_products? block
        !block.text.encode("UTF-8", :undef => :replace, :invalid => :replace).blank? && block.xpath(".//a").any?
      rescue #theses girls puts some little hearts ... not utf-8
        false
      end
      
      def href
        Proc.new { |a| 
          href = a.attribute('href') 
          href.value if href
        }
      end
      
      
    end
  end
end