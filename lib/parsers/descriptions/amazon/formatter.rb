module Descriptions
  module Amazon
    
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
      
      def initialize node
        @headers = headers()
        @table = node
      end
      
      def representation
        # @tables.inject({}) { |hash, table|  
        #   hash[@headers.shift] = table_to_keys_values(table)
        #   hash
        # }
        { key => "toto" }
        
      end
      
      def key
        xpath = (1..5).map { |n| ".//preceding-sibling::h#{n}" } 
        xpath += [".//preceding::div[@class='secHeader']//text()[normalize-space()]"]
        xpath = xpath.join(" | ")
        @table.xpath(xpath).map(&:text).last || DEFAULT_KEY
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
        # @table.xpath(".//div[@class='secHeader']/span").map(&:text) #specific
      end
      
      def keys
        # @nodeset.xpath(".//*[self::h1 or self::h2 or self::h3 or self::h4]").map(&:text)
      end
      
    end
    
    class UlFormatter
      DEFAULT_KEY = "Summary"
      
      def initialize node
        @ul = node
        @lis = @ul.xpath(".//li")
      end
      
      def representation
        { key => @lis.map(&:text) }
      end
      
      def key
        xpath = (1..5).map { |n| 
          "./#{@ul.path.delete('?')}/preceding-sibling::h#{n}"
        }.join(" | ")
        
        @ul.xpath(xpath).map(&:text).last || DEFAULT_KEY
      end
      
    end
    
    class FormatterDetector
      NODES = ['table', 'ul', 'p']
      
      def initialize nodeset
        @nodeset = nodeset.dup
      end
      
      def formatters
        NODES.map { |node|  
          @nodeset.xpath(".//#{node}").map { |xnode| 
            "Descriptions::Amazon::#{node.capitalize}Formatter".constantize.new(xnode) 
          }
        }.flatten
      end
    end
    
    class Formatter
      DEFAULT_KEY = "Header"
      
      def initialize html
        @html = html
        @fragment = Nokogiri::HTML.fragment html
        @key = key()
      end
      
      def representation
        representation = { @key => [] }
        formatters.inject(representation) { |hash, formatter|  
          hash[@key] << formatter.representation
          hash
        }
      end
      
      def key
        @fragment.xpath(".//*[self::h1 or self::h2]").map(&:text).first || DEFAULT_KEY
      end
      
      def formatters
        FormatterDetector.new(@fragment).formatters
      end
    end
  end
end
