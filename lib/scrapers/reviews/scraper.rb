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
      rescue
        report_incident("Run exception")
      end
      
      private
      
      def synchronize reviews
        reviews.each do |review|
          begin
            Scrapers::Reviews::Synchronizer.synchronize review.to_hash
          rescue
            report_incident("url : #{@product.url}, index : #{@index}")
          end
        end
      end
      
      def pages
        (1..1)
      end
      
      def stop_scraping? reviews
        reviews.none? || @product.has_review_for_author?(reviews.first.author)
      end
      
      def report_incident description=nil
        Incident.create(
          :issue => "Reviews Scraper : #{self.class.name}",
          :severity => Incident::INFORMATIVE,
          :description => description,
          :resource_type => 'Product',
          :resource_id => @product.id)
      end
    
    end
  end
end