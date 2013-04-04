module Scrapers::ReverseDirectory
  require 'mechanize'

  class Base 
    def initialize
      @agent = Mechanize.new { |agent|
        agent.user_agent = 'Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1'
      }    
      @result = {}
    end
    
    def result
      @result
    end
    
    def success?
      @result.size == 5
    end
    
    def cleanup str
      ActionView::Base.full_sanitizer.sanitize(str.strip.split.join(" "))
    end
  end

  class Scraper118100 < Base
    def lookup number
      @agent.get("http://www.118000.fr/search?sb_Phone=#{number}") do |page|
        @result[:last_name], @result[:first_name] = cleanup(page.parser.xpath("id('wide-list')/div[6]/div/div[2]/div[1]/a").text).split(" ")
        @result[:address1] = cleanup(page.parser.xpath("id('wide-list')/div[6]/div/div[2]/div[2]/div[2]").text)
        address2 = cleanup(page.parser.xpath("id('wide-list')/div[6]/div/div[2]/div[2]/div[3]").text)
        @result[:zip], @result[:city] = $1, $2 if address2 =~ /^(\d+) (.*)$/
      end
    end
  end
  
  def self.lookup number
    scraper = Scraper118100.new
    scraper.lookup(number)
    scraper.result
  end

end
