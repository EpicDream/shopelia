# -*- encoding : utf-8 -*-

module Scrapers
  module Reviews
    module Fnac
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
          text = @html.search(".//div[@class='lieuDateUser']").text
          text =~ /(\d+\/\d+\/\d+)/
          DateTime.parse_international($1)
        end
        
        def rating
          stars = @html.search("i.i_star").count
        end
        
        def author
          div = @html.search("div.userData").attribute('id').value
        rescue
          nil
        end
        
        def content
          title = @html.xpath('.//div[@class="comment"]//div[@class="title"]').text.clean
          context = @html.xpath('.//div[@class="comment"]//div[@class="context"]').text.clean
          "#{title}. #{context}"
        end
        
      end
    end
  end
end
