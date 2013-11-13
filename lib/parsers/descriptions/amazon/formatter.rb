module Descriptions
  module Amazon
    
    class FormatterDetector
      def initialize nodeset
        @nodeset = nodeset.dup
      end
      
      def formatters
        
        table = @nodeset.xpath(".//table").first
        return TableFormatter if table
        
        ul = @nodeset.xpath(".//ul").first
        return UlLiFormatter if ul
      end
    end
    
    class PFormatter
      
      def initialize nodeset 
        @nodeset = nodeset
        @paragraphs = @nodeset.xpath(".//div/p")
      end
      
      def representation
        @paragraphs.inject({}) { |hash, paragraph|
          key = header_of(paragraph)
          hash[key] ||= []
          hash[key] << paragraph.text
          hash
        }
      end
      
      def header_of paragraph
        xpath = (1..5).map { |n| 
          "./#{paragraph.path.delete('?')}/preceding-sibling::h#{n}"
        }.join(" | ")
        node = @nodeset.xpath(xpath).first
        node.text if node
      end
      
    end
    
    class TableFormatter
      DEFAULT_KEY = "Informations"
      
      attr_reader :key
      
      def initialize nodeset
        @nodeset = nodeset
        @headers = headers()
        @tables = @nodeset.xpath(".//table")
      end
      
      def representation
        @tables.inject({}) { |hash, table|  
          hash[@headers.shift] = table_to_keys_values(table)
          hash
        }
      end
      
      def key
        keys.first || DEFAULT_KEY
      end
      
      def table_to_keys_values table
        table.xpath(".//tr").inject({}) { |hash, tr|  
          key, value = tr.xpath(".//td/text()").map(&:text)
          next hash if key.blank? || value.blank?
          hash[key] = value
          hash
        }
      end
      
      def headers
        @nodeset.xpath(".//div[@class='secHeader']/span").map(&:text) #specific
      end
      
      def keys
        @nodeset.xpath(".//*[self::h1 or self::h2 or self::h3 or self::h4]").map(&:text)
      end
      
    end
    
    class UlLiFormatter
      DEFAULT_KEY = "Résumé"
      
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
