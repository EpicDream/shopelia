# -*- encoding : utf-8 -*-

module Scrapers
  module Reviews
    module RueDuCommerce
      require_relative 'review'
      require_relative '../synchronizer'
      
      class Scraper
        PAGES = (1..1)

        def self.scrape product_id
          product = Product.find(product_id)
          scraper = new(product)
          scraper.run
        end

        def initialize product
          @product = product
          @agent = Mechanize.new
          @agent.user_agent_alias = 'Mac Safari'
        end
      
        def run
          PAGES.each do |index|
            reviews = reviews_of_page(index)
            break if stop_scraping?(reviews)
            reviews.each do |review|
              begin
                Scrapers::Reviews::Synchronizer.synchronize review.to_hash
              rescue => e
                report_incident_at_page(index)
              end
            end
          end
        rescue
          report_incident_at_page("all")
        end

        def reviews_of_page index
          page = @agent.get(@product.url)
          xpath = ".//div[@class='bottomAvis']/preceding-sibling::table[1]//tr[@itemtype='http://schema.org/Review']"
          page.search(xpath).map { |html| RueDuCommerce::Review.new(html, @product.id)}
        end
      
        private
        
        def stop_scraping? reviews
          reviews.none? || @product.has_review_for_author?(reviews.first.author)
        end
        
        def report_incident_at_page index
          Incident.create(
            :issue => "RueDuCommerce reviews scraper",
            :severity => Incident::INFORMATIVE,
            :description => "url : #{@product.url}, page: #{index}",
            :resource_type => 'Product',
            :resource_id => @product.id)
        end
      
      end
    end
  end
end