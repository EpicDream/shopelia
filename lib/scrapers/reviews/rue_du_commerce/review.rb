# -*- encoding : utf-8 -*-

module Scrapers
  module Reviews
    module RueDuCommerce
      class Review
        attr_reader :rank, :author, :content, :product_id
        
        def initialize html, product_id=nil
          @html = html
          @product_id = product_id
        end
        
        def to_hash
          {rating:rating, author:author, content:content, published_at:date, product_id:@product_id}
        end
        
        def date
          meta = @html.search('.//meta[@itemprop="datePublished"]').first
          DateTime.parse_international(meta.attribute("content").value)
        end
        
        def rating
          meta = @html.search('.//meta[@itemprop="ratingValue"]').first
          meta.attribute("content").value.to_i
        end
        
        def author
          @html.xpath('.//b[@itemprop="author"]').first.text
        end
        
        def content
          @html.xpath('.//div[@itemprop="description"]').text.delete("\n").strip
        end
        
      end
    end
  end
end
