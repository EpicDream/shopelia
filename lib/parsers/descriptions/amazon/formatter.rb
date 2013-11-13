module Descriptions
  module Amazon
    
    class FormatterDetector
      def initialize nodeset
        @nodeset = nodeset
      end
      
      def formatter
        ul = @nodeset.xpath(".//ul").first
        UlLiFormatter if ul
      end
    end
    
    class UlLiFormatter
      DEFAULT_KEY = :summary
      
      def initialize nodeset
        @ul = nodeset.xpath(".//ul").first
        @lis = @ul.xpath(".//li")
      end
      
      def representation
        @lis.map(&:text)
      end
      
      def key
        DEFAULT_KEY
      end
      
    end
    
    class Formatter
      
      def initialize html
        @html = html
        @fragment = Nokogiri::HTML.fragment html
      end
      
      def hash_representation
        formatter = node_formatter.new(@fragment)
        {formatter.key => formatter.representation}
      end
      
      def node_formatter
        FormatterDetector.new(@fragment).formatter
      end
    end
  end
end
