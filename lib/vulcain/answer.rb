module Vulcain

  class Answer < Vulcain::Ressource

    def self.create data
      post_request("answers", data)
    end
    
  end
end
