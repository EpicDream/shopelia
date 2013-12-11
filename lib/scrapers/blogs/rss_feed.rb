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
            post_from(item)
          end.compact
        end
      rescue => e
        retry if @feed_urls.any?
        []
      end
      
      def exists?
        !!open(@url)
      rescue
        false
      end
      
      private
      
      def feed_urls
        base = @url.gsub(/\/$/, '')
        ["#{base}/feed/", "#{base}/feeds/posts/default?alt=rss"]
      end
      
      def post_from(item) #rss item
        atom_version = item.respond_to?(:content_encoded) ? 2 : 1
        post = send("post_from_atom_#{atom_version}", item)
        if post.link =~ /feeds/
          report_incident("Post link is rss link #{post.link}")
          return
        end
        content = post.content
        description = post.description
        post.description = Description.extract(description)
        post.images = Images.extract(content)
        post.content = Content.extract(content)
        post.products = ProductsFinder.new(content, post.link).products
        post
      end
      
      def post_from_atom_2(item)
        post = Post.new
        post.content = Nokogiri::HTML.fragment(item.content_encoded)
        post.description = Nokogiri::HTML.fragment(item.description)
        post.published_at = item.pubDate
        post.link = item.link
        post.title = item.title
        post.author = item.author
        post.categories = item.categories.map(&category_name)
        post
      end
      
      def post_from_atom_1(item)
        post = Post.new
        link = item.links.detect { |link| link.type == "text/html" }
        post.content = Nokogiri::HTML.fragment(item.content.content.to_s)
        post.description = Nokogiri::HTML.fragment(item.summary.to_s)
        post.published_at = item.updated.content.to_s
        post.link = link.href.gsub(/#.*$/, '')
        post.title = item.title.content.to_s
        post.author = item.author.name.content.to_s
        post.categories = item.categories.map(&:term)
        post
      end
      
      def category_name
        Proc.new {|category| category.to_s =~ /<category>(.*?)<\/category>/; $1}
      end
      
      def report_incident description=nil
        Incident.create(
          :issue => "Scrapers::Blog::RSSFeed",
          :severity => Incident::INFORMATIVE,
          :description => description)
      end
      
    end
  end
end