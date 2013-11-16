# -*- encoding : utf-8 -*-
module Descriptions
  module Amazon
    
    class KeyCleaner
      SKIP = /commentaires? client|Politique de retour|Votre avis/
      
      def self.clean key
        return nil if key =~ SKIP
        key
      end
    end
    
    class ContentCleaner
      SKIP = /commentaires? client|meilleures ventes d'Amazon/
      
      def self.clean value
        return nil if value =~ SKIP || value.strip.length == 1 
        value.gsub(/\n|\t/, '').strip
      end
    end
    
    class TextFormatter #<node>/text()
      DEFAULT_KEY = "Informations"
      
      def initialize node
        @text = node
      end
      
      def representation
        ContentCleaner.clean @text.text
      end
      
      def key
        KeyCleaner.clean header_of(@text)
      end
      
      private
      
      def header_of div
        xpath = (1..5).map { |n| ".//preceding::h#{n}" }
        xpath += [".//preceding::div[@class='secHeader']//text()[normalize-space()]"]
        xpath = xpath.join(" | ")
        @text.xpath(xpath).map(&:text).last || DEFAULT_KEY
      end
      
    end
    
    class PFormatter
      DEFAULT_KEY = nil
      
      def initialize node 
        @paragraph = node
      end
      
      def representation
        #!inside_table? && 
        ContentCleaner.clean(@paragraph.text)
      end
      
      def key
        KeyCleaner.clean header_of(@paragraph)
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
        return if skip?
        if simple_table?
          table_to_hash()
        else
          #@table.to_s
        end
      end
      
      def skip?
        @table.xpath(".//tr").count <= 1 #table for layout
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
          hash[key] = ContentCleaner.clean(value)
          hash
        }
      end
      
      def simple_table?
        @table.xpath(".//tr").first.xpath(".//td").count <= 2
      rescue
        false
      end
      
    end
    
    class UlFormatter
      DEFAULT_KEY = "Summary"
      
      def initialize node
        @ul = node
        @lis = @ul.xpath(".//li")
      end
      
      def representation
        @lis.map {|li| 
          li.xpath(".//script").map(&:remove)
          ContentCleaner.clean li.text
        }.compact
      end
      
      def key
        xpath = (1..5).map { |n| ".//preceding-sibling::h#{n}" }.join(" | ")
        KeyCleaner.clean(@ul.xpath(xpath).map(&:text).last || DEFAULT_KEY)
      end
      
    end
    
    class FormatterDetector
      NODES = ['table', 'ul', 'p', 'div/text()[normalize-space()]']
      
      def initialize nodeset
        @nodeset = nodeset.dup
      end
      
      def formatters
        NODES.map { |node|  
          @nodeset.xpath(".//#{node}").map { |xnode|
            node = 'text' if node == 'div/text()[normalize-space()]' #TODO
            klass = "Descriptions::Amazon::#{node.camelize}Formatter"
            formatter = klass.constantize.new(xnode) 
          }
        }.flatten
      end
    end
    
    class Formatter
      DEFAULT_KEY = "Header"
      BLOCKS_SEPARATOR = "<!-- SHOPELIA-END-BLOCK -->"
      
      def initialize html
        @html = html
        @fragment = Nokogiri::HTML.fragment html
        @key = key()
      end
      
      def self.format html_blocks
        blocks = html_blocks.split(BLOCKS_SEPARATOR).delete_if { |block| block.blank? }
        blocks.inject({}) { |hash, html| hash.merge!(new(html).representation) }
      end
      
      def representation
        { @key => merged_representations }
      end
      
      def merged_representations
        formatters.inject({}) { |hash, formatter|
          key, content = formatter.key, formatter.representation
          next hash if content.blank? || key.blank?
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