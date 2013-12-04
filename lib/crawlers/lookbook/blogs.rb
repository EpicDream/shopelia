module Crawlers
  module Lookbook
    URL = ->(country) { "http://lookbook.nu/hot/#{country}" }
    Blogger = Struct.new(:name, :avatar, :blog_url, :country)
    GIRLS_FILTER = "http://lookbook.nu/preference/look-list-gender/girls"
    THUMBS_VIEW = "http://lookbook.nu/preference/look-list-view/thumbs"
    MAX_PAGE = 10
    ITEM_XPATH = ".//ul[@id='looks']/li"

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
        page = @agent.get THUMBS_VIEW
        items = page.search(".//ul[@id='looks']/li")
        (1..MAX_PAGE).each do |index|
          page = @agent.get(URL[country, index])
        end
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