# -*- encoding : utf-8 -*-
require 'parsers/descriptions/amazon/formatter'

module Descriptions
  module Formatter
    extend self
    
    #TODO temp, same formatter may be used for all merchants
    
    def format description, url
      result = Descriptions::Amazon::Formatter.format(description).to_json
      log_sample(description, url, result)
      result
    rescue => e
      Incident.report("Descriptions::Formatter", :format, "#{url}")
      return nil
    end
    
    def log_sample description, url, result
      File.open("/tmp/descriptions_formatter", "a+") { |f| 
        f.write("#{url}\n")
        f.write("#{description}\n")
        f.write("#{result}\n")
        f.write("==================================================\n")
      }
    end
    
  end
end
