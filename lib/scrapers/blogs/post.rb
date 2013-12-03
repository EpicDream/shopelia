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
  
    end
  end
end