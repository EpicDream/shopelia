# encoding: UTF-8
require_relative 'post'
require_relative 'rss_feed'
require_relative 'scraper'
require_relative 'images'
require_relative 'content'
require_relative 'description'
require_relative 'products_finder'

module Scrapers
  module Blogs
    URLS = YAML.load_relative_file("blogs.yml")
    
    class Blog
      attr_accessor :url, :posts
      
      def initialize url=nil
        @url = url
        @scraper = Scraper.new
      end
      
      def posts
        return @posts if @posts
        feed =  RSSFeed.new(@url)
        posts = feed.items

        if posts.none? # && !feed.exists?
          @scraper.url = @url
          return @scraper.posts
        end
        
        @posts = posts.map do |post|
          post.description = Description.extract(post.html_description)
          post.images = Images.extract(post.html_content)
          post.content = Content.extract(post.html_content)
          post.products = ProductsFinder.new(post.html_content, @url).products
          post = scrape(post) unless complete?(post)
          post
        end
      rescue => e
        #report incident
        []
      end
      
      def url=url
        @posts = nil
        @url = url
      end
      
      private
      
      def complete? post
        !(post.images.count.zero? || post.content.empty?)
      end
      
      def scrape post
        @scraper.url = post.link
        block = @scraper.blocks.first
        post.images = @scraper.images(block)
        post.content = @scraper.content(block)
        post.products = @scraper.products(block)
        post
      end
      
    end
  end
end