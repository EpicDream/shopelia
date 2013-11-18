# -*- encoding : utf-8 -*-
require 'parsers/descriptions/amazon/formatter'

module Descriptions
  module Formatter
    extend self
    
    #TODO temp, same formatter may be used for all merchants
    
    def format description, url
      Rails.logger = Logger.new("#{Rails.root}/log/descriptions_formatter.log")
      Rails.logger.info("#{url}\n#{description}\n\n")
      Descriptions::Amazon::Formatter.format(description).to_json
    rescue => e
      report_incident_for url
      return nil
    end
    
    def report_incident_for url
      Incident.create(
        :issue => "Description Formatter",
        :severity => Incident::IMPORTANT,
        :description => "#{url}")
    end
    
  end
end
