module Prixing

  class Product < Prixing::Ressource

    def self.get ean
      get_request("api/v4/products/E#{ean}", {})
    end
    
  end
end