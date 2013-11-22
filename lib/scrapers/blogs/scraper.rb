# encoding: UTF-8
require_relative 'images'
require_relative 'content'
require_relative 'products_finder'

module Scrapers
  module Blogs
    
    class Scraper
      attr_accessor :url
      DATE_PATTERN = /(\d{1,2}[\s\.\/]+[a-zA-Z\d]+[\s\.\/]+\d{2,4})/
      
      def initialize url=nil
        @url = url
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
      end
      
      def images block
        Images.extract(block)
      end
      
      def content block
        Content.extract(block)
      end
      
      def products block
        ProductsFinder.new(block, @url).products
      end
      
      def date block
        block.text =~ DATE_PATTERN
        unless $1
          header = block.search(".//preceding::h2").last
          header.text =~ DATE_PATTERN
        end
        Date.parse_international($1) if $1
      end
      
      def link block
        node = header(block).search('.//a').first
        node && node.attribute("href").value
      end
      
      def title block
        node = header(block)
        node && node.text
      end
      
      def posts
        return @posts if @posts
        blocks.map { |block| 
          block.xpath(".//script").map(&:remove) 
          post = Post.new
          post.date = date(block)
          post.link = link(block)
          post.content = content(block)
          post.title = title(block)
          post.images = images(block)
          post.products = products(block)
          post
        }
      end
      
      def blocks
        page = @agent.get(@url)
        page.search("article, div.post, div.blogselection div")
      end
      
      def url=url
        @posts = nil
        @url = url
      end
      
      private
      
      def header block
        block.xpath(".//preceding::h2 | .//preceding::h1 | .//preceding::h3").last
      end
      
    end
    
  end
end