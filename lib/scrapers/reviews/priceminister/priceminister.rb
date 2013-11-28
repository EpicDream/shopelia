# encoding: UTF-8

module Scrapers
  module Reviews
    module Priceminister
      require_relative 'review'
      require_relative '../synchronizer'
      require_relative '../scraper'
      
      class Scraper
        include Scrapers::Reviews::Scraper
        
        URL = ->(product_id) { "http://www.priceminister.com/review?action=list&productid=#{product_id}" }
        FORM_DATA = ->(page) {
          {start:(page - 1)*10, max:10, sort:'FO_MODIFICATION_DATE_DESC'}
        }

        def reviews_of_page index
          data = reviews_url(index)
          page = @agent.post(data[:url], data[:form_data], {'X-AjaxRequest' => 1})
          page.search('.reviewItem').map { |html| Priceminister::Review.new(html, @product.id)}
        end
      
        def reviews_url page=1
          @product_id ||= product_id(@product.url)
          { url:URL[@product_id], form_data:FORM_DATA[page] }
        end
      
        private

        def product_id url
          @agent.get(@product.url)
          url =~ /\/(\d+)/
          $1
        end
      
      end
    end
  end
end