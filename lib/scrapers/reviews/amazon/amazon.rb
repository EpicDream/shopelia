module Scraper
  module Reviews
    class Amazon
      URL = ->(asin, page) { "http://www.amazon.fr/product-reviews/#{asin}/?pageNumber=#{page}&showViewpoints=0&sortBy=byRankDescending" }

      def self.scrape product_id
        product = Product.find(product_id)
        scraper = new(product)
      end

      def initialize product
        @product = product
        @asin = asin(@product.url)
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