module Crawlers
  module Lookbook
    URL = ->(country) { "http://lookbook.nu/hot/#{country}" }
    Blog = Struct.new(:name, :avatar, :url, :country)
    GIRLS_FILTER = "http://lookbook.nu/preference/look-list-gender/girls"
    
    class Blogs
      
      def initialize country="france"
        @url = URL[country]
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
      end
      
      def run
        @agent.get @url
        page = @agent.get GIRLS_FILTER
        page.search(".//ul[@id='looks']/li")
      end
      
      def all
        
      end
    end
    
  end
end