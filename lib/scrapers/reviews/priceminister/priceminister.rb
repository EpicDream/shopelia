# -*- encoding : utf-8 -*-

module Scrapers
  module Reviews
    module Priceminister
      require_relative 'review'
      require_relative '../synchronizer'
      
      class Scraper
        PAGES = (1..10)
        URL = ->(product_id) { "http://www.priceminister.com/review?action=list&productid=#{product_id}" }
        FORM_DATA = ->(page) {
          {start:(page - 1)*10, max:10, sort:'FO_MODIFICATION_DATE_DESC'}
        }

        def self.scrape product_id
          product = Product.find(product_id)
          scraper = new(product)
          scraper.run
        end

        def initialize product
          @product = product
          @product_id = product_id(@product.url)
          @agent = Mechanize.new
          @agent.user_agent_alias = 'Mac Safari'
        end
      
        def run
          @agent.get(@product.url)
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
          data = reviews_url(index)
          page = @agent.post(data[:url], data[:form_data], {'X-AjaxRequest' => 1})
          page.search('.reviewItem').map { |html| Priceminister::Review.new(html, @product.id)}
        end
      
        def reviews_url page=1
          { url:URL[@product_id], form_data:FORM_DATA[page] }
        end
      
        private
        
        def stop_scraping? reviews
          reviews.none? || @product.has_review_for_author?(reviews.first.author)
        end
        
        def report_incident_at_page index=nil
          Incident.create(
            :issue => "PriceMinister reviews scraper",
            :severity => Incident::INFORMATIVE,
            :description => "url : #{URL[@product_id]}, page : #{index}",
            :resource_type => 'Product',
            :resource_id => @product.id)
        end
      
        def product_id url
          url =~ /\/(\d+)/
          $1
        end
      
      end
    end
  end
end