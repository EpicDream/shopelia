# -*- encoding : utf-8 -*-

module Scrapers
  module Reviews
    extend self
    DOMAINS = {
      "amazon.fr" => 'amazon',
      # "priceminister.com" => 'priceminister',
      "rueducommerce.fr" => 'rue_du_commerce',
      "fnac.com" => "fnac"
    }
    
    def requires merchant
      require "scrapers/reviews/#{merchant}/#{merchant}"
    end
    
    def scraper merchant
      requires merchant
      "Scrapers::Reviews::#{merchant.camelize}::Scraper".constantize
    end
    
    def scrape product
      return unless merchant = DOMAINS[product.merchant.domain]
      scraper(merchant).scrape(product.id)
    end
  end
  
end
