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
      
      def texts post
        post.xpath(".//text()").text
      end
      
      def posts
        page = @agent.get(@url)
        posts = page.search("article, div.post, div.blogselection div")
        posts.map { |post| post.xpath(".//script").map(&:remove) }
        posts
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