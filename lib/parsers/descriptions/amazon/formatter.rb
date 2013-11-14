module Descriptions
  module Amazon
    
    class PFormatter
      DEFAULT_KEY = "Informations"
      
      def initialize node 
        @paragraph = node
      end
      
      def representation
        !inside_table? && @paragraph.text
      end
      
      def key
        header_of(@paragraph)
      end
      
      private
      
      def inside_table?
        @paragraph.xpath(".//ancestor::table").any?
      end
      
      def header_of paragraph
        xpath = (1..5).map { |n| ".//preceding-sibling::h#{n}" }.join(" | ")
        @paragraph.xpath(xpath).map(&:text).last || DEFAULT_KEY
      end
      
    end
    
    class TableFormatter
      DEFAULT_KEY = "Informations"
      
      attr_reader :key
      
      def initialize node
        @table = node
      end
      
      def representation
        if simple_table?
          table_to_hash()
        else
          @table.to_s
        end
      end
      
      def key
        xpath = (1..5).map { |n| ".//preceding-sibling::h#{n}" } 
        xpath += [".//preceding::div[@class='secHeader']//text()[normalize-space()]"]
        xpath = xpath.join(" | ")
        @table.xpath(xpath).map(&:text).last || DEFAULT_KEY
      end
      
      def table_to_hash
        @table.xpath(".//tr").inject({}) { |hash, tr|  
          key, value = tr.xpath(".//td/text()").map(&:text)
          next hash if key.blank? || value.blank?
          hash[key] = value
          hash
        }
      end
      
      def simple_table?
        @table.xpath(".//tr").first.xpath(".//td").count <= 2
      end
      
    end
    
    class UlFormatter
      DEFAULT_KEY = "Summary"
      
      def initialize node
        @ul = node
        @lis = @ul.xpath(".//li")
      end
      
      def representation
        @lis.map(&:text)
      end
      
      def key
        xpath = (1..5).map { |n| ".//preceding-sibling::h#{n}" }.join(" | ")
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
        {@key => merged_representations}
      end
      
      def merged_representations
        formatters.inject({}) { |hash, formatter|
          key, content = formatter.key, formatter.representation
          next hash if content.blank?
          hash[key] ||= []
          hash[key] << content
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
