module Vulcain

  class ProductInformations < Vulcain::Ressource

    def self.create data
      post_request("product_informations", data)
    end
    
  end
end
