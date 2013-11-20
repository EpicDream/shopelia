module Scrapers
  module Blogs
    URLS = YAML.load_relative_file("blogs.yml")

    class Scraper
      attr_accessor :url
      
      def initialize url=nil
        @url = url
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
      end
      
      def images post
        post.xpath('.//img').map(&src).compact
      end
      
      def posts
        page = @agent.get(@url)
        page.search("article, div.post, div.blogselection div")
      end
      
      private
      
      def src
        Proc.new { |img| 
          src = img.attribute('src').value 
          src if src =~ /^http/
        }
      end
    end
  end
end