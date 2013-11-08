module Scrapers
  module Reviews
    module Amazon
      require_relative 'review'
      require_relative '../synchronizer'
      
      class Scraper
        PAGES = (1..10)
        URL = ->(asin, page) { "http://www.amazon.fr/product-reviews/#{asin}/?pageNumber=#{page}&showViewpoints=0&sortBy=bySubmissionDateDescending" }

        def self.scrape product_id
          product = Product.find(product_id)
          scraper = new(product)
          scraper.run
        end

        def initialize product
          @product = product
          @asin = asin(@product.url)
          @agent = Mechanize.new
          @agent.user_agent_alias = 'Mac Safari'
        end
      
        def run
          PAGES.each do |index|
            Reviews::Syncronizer.synchronize reviews_of_page(index)
          end
        end

        def reviews_of_page index
          xpath = "//table[@id='productReviews']//div[@class='reviews-voting-stripe']/ancestor::div[2]"
          page = @agent.get reviews_url(index)
          page.search(xpath).map { |html| Amazon::Review.new(html, @product.id)}
        end
      
        def reviews_url page=1
          URL[@asin, page]
        end
      
        private
      
        def asin url
          url[/[^\/]+$/]
        end
      
      end
    end
  end
end