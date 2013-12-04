module Crawlers
  module Lookbook
    URL = ->(country) { "http://lookbook.nu/hot/#{country}" }
    Blogger = Struct.new(:name, :avatar, :blog_url, :country)
    GIRLS_FILTER = "http://lookbook.nu/preference/look-list-gender/girls"
    
    class Blogs
      
      def initialize country="france"
        @url = URL[country]
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
      end
      
      def run
      end
      
      def items
        @agent.get @url
        page = @agent.get GIRLS_FILTER
        page.search(".//ul[@id='looks']/li")
      end
      
      def page item
        
      end
      
      def blog_url page
        
      end
      
      def avatar page
        
      end
      
      def name page
        
      end
    end
    
  end
end