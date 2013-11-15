module Descriptions
  module Formatter
    extend self
    
    #TODO temp, same formatter may be used for all merchants
    
    def format product
      return unless product.merchant.domain == "amazon.fr"
      representation = Descriptions::Amazon::Formatter.format(product.description)
      product.update_attributes(json_description: representation.to_json)
    rescue => e
      report_incident_for product
    end
    
    def report_incident_for product
      Incident.create(
        :issue => "Description Formatter",
        :severity => Incident::IMPORTANT,
        :description => "product_id : #{product.id}",
        :resource_type => 'Product',
        :resource_id => @product.id)
    end
    
  end
end
