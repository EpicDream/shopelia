# encoding: UTF-8

module Scrapers
  module Reviews
    module Amazon
      require_relative 'review'
      require_relative '../synchronizer'
      require_relative '../scraper'
      
      class Scraper
        include Scrapers::Reviews::Scraper
        URL = ->(asin, page) { "http://www.amazon.fr/product-reviews/#{asin}/?pageNumber=#{page}&showViewpoints=0&sortBy=bySubmissionDateDescending" }

        def reviews_of_page index
          xpath = "//table[@id='productReviews']//div[@class='reviews-voting-stripe']/ancestor::div[2]"
          page = @agent.get reviews_url(index)
          page.search(xpath).map { |html| Amazon::Review.new(html, @product.id)}
        end

        def reviews_url page=1
          URL[asin(@product.url), page]
        end
      
        private
        
        def asin url
          @asin ||= url[/[^\/]+$/]
        end
      
      end
    end
  end
end