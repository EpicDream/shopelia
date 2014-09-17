require 'instagram'

class InstagramConnect
  CREDENTIALS = YAML.load_relative_file("account.yml")['instagram']
  
  attr_reader :client
  
  def initialize access_token
    authenticate(access_token)
    @client = ::Instagram::Client.new
  end
  
  def followers
    all_pages(:user_followed_by)
  end
  
  def followings
    all_pages(:user_follows)
  end
  
  def me
    @client.user
  end
  
  private
  
  def all_pages action, user_id=me.id
    next_cursor = nil
    users = []
    begin
      response = ::Instagram.send(action, user_id, { count:100, cursor:next_cursor })
      next_cursor = response.pagination.next_cursor
      users += response
    end while next_cursor
    users
  end

  def authenticate access_token
    ::Instagram.configure do |config|
      config.client_id = CREDENTIALS['client_id']
      config.client_secret = CREDENTIALS['client_secret']
      config.access_token = access_token
    end
  end
  
end
