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
          content = meta.attribute("content").value if meta
          content = @html.search('.//div[@class="date"]/span').first.text unless content
          DateTime.parse_international(content)
        end
        
        def rating
          meta = @html.search('.//meta[@itemprop="ratingValue"]').first
          return meta.attribute("content").value.to_i if meta
          style = @html.search('.ficheProductRatingyellow').first.attribute("style").value
          style =~ /(\d+)/ #does it not really suck !?
          $1.to_i * 5/100
        end
        
        def author
          content = @html.xpath('.//b[@itemprop="author"]').first
          return content.text if content
          @html.search('.//div[@class="firstname"]/span').first.text
        end
        
        def content
          content = @html.xpath('.//div[@itemprop="description"]').first
          return content.text.clean if content
          @html.search('.//div[@class="commentaire"]').first.text.clean
        end
        
      end
    end
  end
end
