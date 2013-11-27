# encoding: UTF-8

module Scrapers
  module Blogs
    class Post 
      attr_accessor :published_at, :link, :content, :description, :images, :products, :title, :author, :categories
      
      def initialize
        @images = []
        @products = []
        @categories = []
      end
      
      def from item #rss item
        content = Nokogiri::HTML.fragment item.content_encoded
        description = Nokogiri::HTML.fragment item.description
        self.published_at = item.pubDate
        self.link = item.link
        self.title = item.title
        self.author = item.author
        self.categories = item.categories.map(&category_name)
        self.description = Description.extract(description)
        self.images = Images.extract(content)
        self.content = Content.extract(content)
        self.products = ProductsFinder.new(content, self.link).products
        self
      end
      
      def modelize
        post = ::Post.new
        [:published_at, :link, :content, :description, :title, :author].each { |attribute|
          post.send("#{attribute}=", self.send(attribute))
        }
        [:images, :products, :categories].each { |attribute|
          post.send("#{attribute}=", self.send(attribute).to_json)
        }
        post
      end
  
      private
  
      def category_name
        Proc.new {|category| category.to_s =~ /<category>(.*?)<\/category>/; $1}
      end
  
    end
  end
end