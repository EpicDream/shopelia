require 'instagram'

module AnneFashion
  class Instagram
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['instagram']
    MAX_FOLLOW_PER_SESSION = 20
     
    attr_reader :client
    
    def initialize
      authenticate
      @client = ::Instagram::Client.new
    end
    
    def follow_and_like_by_tag tag='fashion'
      session_wait()
      medias = search(tag).sample follow_count()
      medias.each do |media|
        next unless media.caption
        begin
          follow media.caption.from.id
          wait(min=10)
          like media.caption.id rescue("Cannot like")
          wait
        rescue
          next
        end
      end
    end
    
    def me
      @client.user
    end
    
    def search tag='fashion', max=40
      @client.tag_recent_media(tag, count:max)
    end
    
    def follow user_id
      @client.follow_user(user_id)
    end
    
    def like media_id
      @client.like_media(media_id)
    end

    private
    
    def follow_count
      rand(12..MAX_FOLLOW_PER_SESSION)
    end
    
    def wait min=4
      sleep rand(min..20)
    end
    
    def session_wait
      sleep rand(60..3600)
    end
    
    def authenticate
      ::Instagram.configure do |config|
        config.client_id = CREDENTIALS['client_id']
        config.client_secret = CREDENTIALS['client_secret']
        config.access_token = CREDENTIALS['access_token']
      end
    end
    
  end
end