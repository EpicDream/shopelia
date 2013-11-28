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
        @filters = YAML.load_relative_file("urls_filters.yml")
      end
      
      def products
        products = @blocks.inject({}) do |products, block|
          products.merge!(products_in_a_tag(block))
          products.merge!(products_in_map_tag(block))
        end
        Hash[*products.to_a.uniq {|k,v| v}.flatten]
      end
      
      def blocks
        content = @html.search(".entry-content").first || @html
        content.search(".//div | .//p | .//map")
      end
      
      private
      
      def products_in_a_tag block
        block.xpath(".//a").inject({}) { |products, a|
          link = href[a]
          next products if remove?(link)
          products.merge!({"#{a.text}" => link})
        }
      end
      
      def products_in_map_tag block
        index = 0
        block.xpath(".//area").inject({}) { |products, area|
          link = href[area]
          next products if remove?(link)
          index += 1
          products.merge!({"Produit(#{index})" => link})
        }
      end
      
      def remove? url
        @filters.each do |filter|
          return true if url =~ Regexp.new(filter, true)
        end
        URI(url).host == URI(@url).host 
      rescue true 
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