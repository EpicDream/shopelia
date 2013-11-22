# encoding: UTF-8
require 'rss'
require 'open-uri'

module Scrapers
  module Blogs
    class RSSFeed
      def initialize url
        @url = "#{url.gsub(/\/$/, '')}/feed/"
      end
      
      def items
        open(@url) do |rss|
          feed = RSS::Parser.parse(rss)
          feed.items.map do |item|
            Post.new.from(item)
          end
        end 
      rescue
        #report info incident
        []
      end
      
      def exists?
        !!open(@url)
      rescue
        false
      end
      
    end
  end
end