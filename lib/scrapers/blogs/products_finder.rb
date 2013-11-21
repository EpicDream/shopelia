# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class ProductsFinder
      
      def initialize html, url
        @html = html
        @url = url
        @blocks = blocks()
      end
      
      def products
        candidate = nil
        @blocks.each do |block|
          next unless may_include_products?(block)
          candidate = block
        end
        candidate ||= @blocks.last
        return {} unless candidate 
        {text:candidate.text, links:links(candidate)}
      end
      
      def blocks
        content = @html.search(".entry-content").first || @html
        content.search(".//div | .//p")
      end
      
      private
      
      def links block
        links = block.xpath(".//a").map(&href)
        links.delete_if { |link| link =~ Regexp.new(@url) }
      end
      
      def may_include_products? block
        !block.text.blank? && block.xpath(".//a").any?
      end
      
      def href
        Proc.new { |a| 
          a.attribute('href').value
        }
      end
      
      
    end
  end
end