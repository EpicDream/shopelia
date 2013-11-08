module Scrapers
  module Reviews
    module Amazon
      class Review
        attr_reader :rank, :author, :content
        
        def initialize html
          @html = html
        end
        
        def rank
          text = @html.search(".swSprite").text
          text.match(/(\d\.0)\s+étoiles/).captures.first.to_i
        end
        
        def author
          href = @html.xpath('.//a[1]').first.attributes['href'].value
          href.match(/profile\/(.*?)\//).captures.first
        end
        
        def content
          @html.xpath('./text()[normalize-space()]').text.delete("\n").strip
        end
        
      end
    end
  end
end
