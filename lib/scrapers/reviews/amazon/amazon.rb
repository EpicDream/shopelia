# -*- encoding : utf-8 -*-

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
          xpath = "//table[@id='productReviews']//div[@class='reviews-voting-stripe']/ancestor::div[2]"
          page = @agent.get reviews_url(index)
          page.search(xpath).map { |html| Amazon::Review.new(html, @product.id)}
        end
      
        def reviews_url page=1
          URL[@asin, page]
        end
      
        private
        
        def stop_scraping? reviews
          reviews.none? || @product.has_review_for_author?(reviews.first.author)
        end
        
        def report_incident_at_page index
          Incident.create(
            :issue => "Amazon reviews scraper",
            :severity => Incident::INFORMATIVE,
            :description => "url : #{reviews_url(index)}",
            :resource_type => 'Product',
            :resource_id => @product.id)
        end
      
        def asin url
          url[/[^\/]+$/]
        end
      
      end
    end
  end
end