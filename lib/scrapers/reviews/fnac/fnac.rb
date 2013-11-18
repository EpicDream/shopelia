# encoding: UTF-8

module Scrapers
  module Reviews
    module Fnac
      require_relative 'review'
      require_relative '../synchronizer'
      require_relative '../scraper'
      
      class Scraper
        include Scrapers::Reviews::Scraper

        def reviews_of_page index
          xpath = '//*[@id="avisinternautes"]//ul/li'
          page = @agent.get reviews_url(index)
          page.search(xpath).map { |html| Fnac::Review.new(html, @product.id)}
        end

        def reviews_url page=1
          @product.url
        end
      
      end
    end
  end
end