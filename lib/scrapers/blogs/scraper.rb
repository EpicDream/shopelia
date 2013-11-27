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
          header.text =~ DATE_PATTERN if header
        end
        date = Date.parse_international($1) if $1 rescue nil
        date || Time.now
      end
      
      def link block
        header = header(block)
        node = header.search('.//a').first if header
        href = node && node.attribute("href").value
        href = @url + href unless href =~ Regexp.new(URI(@url).host)
        href
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
          post.published_at = date(block)
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
        page.search("article, div.post, div.blogselection > div")
      end
      
      def url=url
        @posts = nil
        @url = url
      end
      
      private
      
      def header block
        header_in = block.xpath(".//h1 | .//h2").first
        header_out = block.xpath(".//preceding::h2 | .//preceding::h1 | .//preceding::h3").last
        header_in || header_out
      end
      
    end
    
  end
end