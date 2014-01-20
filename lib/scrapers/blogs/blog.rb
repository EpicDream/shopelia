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
        Mechanize.new.get(@url) #to check if url still exists
        feed =  RSSFeed.new(@url)

        @posts = feed.items.map do |post|
          post = scrape(post) unless complete?(post)
          post
        end

        if @posts.none?
          @scraper.url = @url
          @posts = @scraper.posts
        end
        @posts
      rescue => e
        message = @posts && @posts.none? ? "No posts - #{@url}" : "Exception - #{@url} #{e.message}"
        Incident.report("Scrapers::Blogs::Blog", :posts, message)
        []
      end
      
      def url=url
        @posts = nil
        @url = url
      end
      
      private
      
      def complete? post
        post.images.count > 1 && !post.content.empty?
      end
      
      def scrape post
        @scraper.url = post.link
        return post unless block = @scraper.blocks.first
        post.images = @scraper.images(block)
        post.content = @scraper.content(block)
        post.products = @scraper.products(block)
        post
      end
      
    end
  end
end