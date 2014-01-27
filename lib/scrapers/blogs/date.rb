# encoding: UTF-8

module Scrapers
  module Blogs
    class Date
      DATE_PATTERN = /(\d{1,2}[\s\.\/]+[a-zA-Z\d]+[\s\.\/]+\d{2,4})|([a-zA-Z\d]+[\s\.\/]+\d{1,2}[\s\.\/]+\d{2,4})/
      DATE_NODE_XPATH = ".//*[@itemprop='datePublished'] | .//time"
      DATE_NODE_ATTRIBUTES = ["title", "datetime"]
      HEADER_XPATH = ".//preceding::h2"
      
      def initialize document
        @document = document
        @header = document.search(HEADER_XPATH).last
      end
      
      def extract
        extract_from_date_node || extract_from_text || extract_from_text(@header)
      end
      
      private
      
      def extract_from_text document=@document
        return unless document
        document.text.unaccent.downcase =~ DATE_PATTERN
        return unless date = $1 || $2
        date =~ /\.(\d\d)$/ ? date[-2..-1] = "20#{$1}" : date
        return unless date = ::Date.parse_international(date) rescue nil
        date = ::Date.today if date > ::Date.today #in case of parse error
        date
      end
      
      def extract_from_date_node
        return unless node = @document.search(DATE_NODE_XPATH).first
        DATE_NODE_ATTRIBUTES.inject(nil) { |date, attribute| 
          begin 
            date = node.attribute(attribute).value rescue nil
            break ::Date.parse_international(date) if date
          rescue 
            nil
          end
        }
      end
      
    end
  end
end