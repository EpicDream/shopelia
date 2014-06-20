require 'twitter'

class TwitterConnect
  CREDENTIALS = YAML.load_relative_file("account.yml")['twitter']

  attr_reader :client
  
  def initialize access_token, access_token_secret
    @client = authenticate(access_token, access_token_secret)
  end
  
  def me
    client.current_user
  end
  
  def friends_ids
    client.friend_ids(me).attrs[:ids].map(&:to_s)
  end
  
  private
  
  def authenticate access_token, access_token_secret
    ::Twitter::REST::Client.new do |config|
      config.consumer_key = CREDENTIALS['consumer_key']
      config.consumer_secret = CREDENTIALS['consumer_secret']
      config.access_token = access_token
      config.access_token_secret = access_token_secret
    end
  end
  
end
