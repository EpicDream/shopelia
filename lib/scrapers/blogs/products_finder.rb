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
        @blocks.inject({}) do |products, block|
          block.xpath(".//a").each { |a|
            link = href[a]
            next if products.values.include?(link) || remove?(link)
            products.merge!({"#{a.text}" => link})
          }
          products
        end
      end
      
      def blocks
        content = @html.search(".entry-content").first || @html
        content.search(".//div | .//p")
      end
      
      private
      
      def remove? url #use a yaml file  for filters
        URI(url).host == URI(@url).host rescue true 
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