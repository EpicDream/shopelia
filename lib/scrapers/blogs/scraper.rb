# encoding: UTF-8
require_relative 'images'
require_relative 'content'
require_relative 'products_finder'

module Scrapers
  module Blogs
    
    class Scraper
      attr_accessor :url
      
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
        "TODO"
      end
      
      def link block
        "TODO"
      end
      
      def title block
        "TODO"
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
      
    end
    
  end
end