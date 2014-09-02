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

        @posts = feed.items.map do |post|
          post = scrape(post) unless complete?(post)
          post
        end

        if @posts.none?
          @scraper.url = @url
          @posts = @scraper.posts
        end

        if @posts.none? || (@posts.one? && @posts.first.link == @url) #blog with items entries on home page
          urls = @scraper.posts_urls
          @posts = urls.map { |url| 
            @scraper.url = url
            @scraper.posts.first
          }
        end
        
        @posts
      rescue => e
        Rails.logger.error(%Q{[#{Time.now}] [Blog#posts] #{e.backtrace.join("\n")}})
        message = "Exception - #{@url} #{e.message}"
        Incident.report("Scrapers::Blogs::Blog", :posts, message)
        []
      end
      
      def url=url
        @posts = nil
        @url = url
      end
      
      private
      
      def complete? post
        post.images.count >= 2 && !post.content.empty?
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