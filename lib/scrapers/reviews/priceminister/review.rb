# -*- encoding : utf-8 -*-

module Scrapers
  module Reviews
    module Priceminister
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
          DateTime.parse_international(meta.attribute("content"))
        end
        
        def rating
          @html.search('.//span[@itemprop="reviewRating"]').text.to_i
        end
        
        def author
          @html.xpath('.//span[@itemprop="author"]').first.text
        end
        
        def content
          @html.xpath('.//blockquote[@itemprop="reviewBody"]').text.clean
        end
        
      end
    end
  end
end
