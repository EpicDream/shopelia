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
        date = $1
        date =~ /\.(\d\d)$/ ? date[-2..-1] = "20#{$1}" : date 
        date = Date.parse_international(date) if date rescue nil
        date = Time.now if date.nil? || date > Date.today #in case of parse error
        date
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
      
      def blocks
        page = @agent.get(@url)
        page = from_blogspot_frame(page) || page
        page.search("article, div.post, div.blogselection > div, div.entry, div.single, div.post-wrap, div.post-body, div.article, div.blog_item, div.entrybody")
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
       @agent.get(@url)
      end
      
      def header block
        header_in = block.xpath(".//h1 | .//h2 | .//h3").first
        header_out = block.xpath(".//preceding::h2 | .//preceding::h1 | .//preceding::h3").last
        header_in || header_out
      end
      
    end
    
  end
end