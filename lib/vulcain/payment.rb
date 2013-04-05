module Vulcain

  class Payment < Vulcain::Ressource

    def self.create data
      post_request("payments", data)
    end
    
  end
end
