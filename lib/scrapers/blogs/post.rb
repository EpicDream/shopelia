# encoding: UTF-8

module Scrapers
  module Blogs
    class Post 
      attr_accessor :published_at, :link, :content, :description, :images, :products, :title, :author, :categories
      attr_accessor :html_description, :html_content
  
      def from item #rss item
        self.published_at = item.pubDate
        self.link = item.link
        self.html_content = Nokogiri::HTML.fragment item.content_encoded
        self.html_description = Nokogiri::HTML.fragment item.description
        self.title = item.title
        self.author = item.author
        self.categories = item.categories.map(&category_name)
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