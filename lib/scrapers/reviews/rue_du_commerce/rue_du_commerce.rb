# encoding: UTF-8

module Scrapers
  module Reviews
    module RueDuCommerce
      require_relative 'review'
      require_relative '../synchronizer'
      require_relative '../scraper'
      
      class Scraper
        include Scrapers::Reviews::Scraper

        def reviews_of_page index
          page = @agent.get(@product.url)
          xpath = ".//div[@class='bottomAvis']/preceding-sibling::table[1]//tr[@itemtype='http://schema.org/Review']"
          page.search(xpath).map { |html| RueDuCommerce::Review.new(html, @product.id)}
        end
      
      end
    end
  end
end