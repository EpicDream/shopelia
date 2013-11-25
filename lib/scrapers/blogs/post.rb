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
        self.published_at = item.pubDate
        self.link = item.link
        self.title = item.title
        self.author = item.author
        self.categories = item.categories.map(&category_name)
        self.description = Description.extract(item.description)
        self.images = Images.extract(item.content_encoded)
        self.content = Content.extract(item.content_encoded)
        self.products = ProductsFinder.new(item.content_encoded, self.link).products
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