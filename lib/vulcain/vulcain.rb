module Vulcain

  require 'json'
  require 'base64'
  require 'openssl'
  require 'net/http'

  class Configuration
    attr_accessor :base_url, :api_key

    def base_url
      "http://vulcain.shopelia.fr:3000"
    end
    
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

end
