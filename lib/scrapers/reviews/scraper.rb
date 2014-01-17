# encoding: UTF-8
# Reviews scraper module included in merchants reviews scrapers

module Scrapers
  module Reviews
    module Scraper
      
      def self.included base
        def base.scrape product_id
          product = Product.find(product_id)
          scraper = new(product)
          scraper.run
        end
      end

      def initialize product
        @product = product
        @agent = Mechanize.new
        @agent.user_agent_alias = 'Mac Safari'
      end
    
      def run
        pages.each do |index|
          @index = index
          reviews = reviews_of_page(index)
          break if stop_scraping?(reviews)
          synchronize(reviews)
        end
      rescue => e
        return if e.respond_to?(:response_code) && e.response_code.to_i == 404
        Incident.report("Scrapers::Reviews::Scraper", :run, "Run exception")
      end
      
      private
      
      def synchronize reviews
        reviews.each do |review|
          begin
            Scrapers::Reviews::Synchronizer.synchronize review.to_hash
          rescue
            Incident.report("Scrapers::Reviews::Scraper", :synchronize, "url : #{@product.url}, index : #{@index}")
          end
        end
      end
      
      def pages
        (1..1)
      end
      
      def stop_scraping? reviews
        reviews.none? || @product.has_review_for_author?(reviews.first.author)
      end

    end
  end
end