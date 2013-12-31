require 'instagram'

module AnneFashion
  class Instagram
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['instagram']
    
    attr_reader :client
    
    def initialize
      authenticate
      @client = ::Instagram::Client.new
    end
    
    def me
      @client.user
    end

    private
    
    def authenticate
      ::Instagram.configure do |config|
        config.client_id = CREDENTIALS['client_id']
        config.client_secret = CREDENTIALS['client_secret']
        config.access_token = CREDENTIALS['access_token']
      end
    end
    
  end
end