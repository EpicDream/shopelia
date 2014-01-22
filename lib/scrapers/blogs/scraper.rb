# encoding: UTF-8
require_relative 'images'
require_relative 'content'
require_relative 'products_finder'
require_relative 'date'

module Scrapers
  module Blogs
    
    class Scraper
      attr_accessor :url
      POST_NODE_XPATHS = [
        "article", "div.post", "div.blogselection > div", "div.entry", "div.single", "div.post-wrap", "div.post-body", 
        "div.article", "div.blog_item", "div.entrybody", "div.content-box", "div#content"
      ]
      
      def initialize url=nil
        @url = url
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
      end
      
      def images block
        images = Images.extract(block)
        if images.count <= 1 #images can be on post page but not on blog posts list
          block = blocks(link(block)).first
          Images.extract(block.search(".//ancestor::*"))
        end
      end
      
      def content block
        Content.extract(block)
      end
      
      def products block
        ProductsFinder.new(block, @url).products
      end
      
      def date block
        Date.new(block).extract
      end
      
      def link block
        header = header(block)
        node = header.search('.//a').first if header
        href = node && node.attribute("href").value
        return @url unless href
        href = @url + href unless href =~ /http/
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
      
      def blocks url=@url
        page = @agent.get(url)
        page = from_blogspot_frame(page) || page
        POST_NODE_XPATHS.each { |xpath|  
          blocks = page.search(xpath)
          return blocks if blocks.any?
        }
        []
      rescue 
        []
      end
      
      def url=url
        @posts = nil
        @url = url
      end
      
      private
      
      def from_blogspot_frame page
       return unless frame = page.search(".//frame[contains(@src, 'blogspot')]").first
       src = frame.attribute('src').value
       @url = src
       @agent.get(@url) rescue nil
      end
      
      def header block
        header_in = block.xpath(".//h1 | .//h2 | .//h3").first
        header_out = block.xpath(".//preceding::h2 | .//preceding::h1 | .//preceding::h3").last
        header_in || header_out
      end
      
    end
    
  end
end