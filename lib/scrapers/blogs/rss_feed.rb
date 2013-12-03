# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class RSSFeed
      
      def initialize url
        @url = url
        @feed_urls = feed_urls()
      end
      
      def items
        open(@feed_urls.shift) do |rss|
          feed = RSS::Parser.parse(rss)
          feed.items.map do |item|
            Post.new.from(item)
          end
        end
      rescue => e
        retry if @feed_urls.any?
        []
      end
      
      def feed_urls
        base = @url.gsub(/\/$/, '')
        ["#{base}/feed/", "#{base}/feeds/posts/default"]
      end
      
      def exists?
        !!open(@url)
      rescue
        false
      end
      
    end
  end
end