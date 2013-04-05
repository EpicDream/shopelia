module Vulcain

  class Order < Vulcain::Ressource

    def self.create data
      post_request("orders", data)
    end
    
  end
end
