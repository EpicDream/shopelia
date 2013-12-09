# encoding: UTF-8

module Crawlers
  module Lookbook
    BASE_URL = "http://lookbook.nu/hot"
    URL = ->(country, page=nil) { "#{BASE_URL}/#{country}/#{page}" }
    GIRLS_FILTER = "http://lookbook.nu/preference/look-list-gender/girls"
    THUMBS_VIEW = "http://lookbook.nu/preference/look-list-view/thumbs"
    MAX_PAGE = 10
    ITEM_XPATH = ".//ul[@id='looks']/li"
    
    class Blogs
      
      def initialize country="france"
        @country = country
        @iso_country = Country.find_by_name(country.capitalize).iso
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
        @agent.get BASE_URL
        apply_filters()
      end
      
      def fetch
        items.map { |item| 
          blog = blog(item)
          blog.save if blog
        }
      end
      
      def items opts={}
        page = @agent.get URL[@country]
        items = page.search(ITEM_XPATH).to_a
        max_page = opts[:max_page] || MAX_PAGE
        (2..max_page).each do |index|
          page = @agent.get(URL[@country, index])
          res = page.search(ITEM_XPATH).to_a
          break if res.empty?
          items += res
        end
        items
      end
      
      def blog item
        @page, href = page(item)
        Blog.new(name:name(), url:blog_url(), country:@iso_country, avatar_url:avatar_url(), scraped:false)
      end
      
      def page item
        link = item.search(".//div[@class='minilook_details']/p/a").first
        href = link.attribute("href")
        [@agent.get(href), href]
      end
      
      def blog_url
        link = @page.search('//div[@itemprop="author"]//a[@itemprop="url" and @rel="nofollow"]')
        link.attribute("href").value
      rescue
        nil #no link found, some have no blog url
      end
      
      def avatar_url
        img = @page.search('//*[@id="userheader"]//img[@itemprop="image"]')
        img.attribute("src").value
      end
      
      def name
        name = @page.search('//*[@id="userheader"]//a[@itemprop="name"]')
        name.text
      end
      
      private
      
      def apply_filters
        @agent.get GIRLS_FILTER
        @agent.get THUMBS_VIEW
      end
    end
    
  end
end