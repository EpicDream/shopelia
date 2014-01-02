require 'instagram'

module AnneFashion
  class Instagram
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['instagram']
    MAX_FOLLOW_PER_SESSION = 20
    MAX_UNFOLLOW_PER_SESSION = 10
    
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
    
    def schedule_follow_ratio
      session_wait()
      unfollow_sample.each do |user_id|
        unfollow(user_id)
        wait(min=10)
      end
    end
    
    def unfollow_sample
      (followings.map(&:id) - followers.map(&:id)).sample(MAX_UNFOLLOW_PER_SESSION)
    end
    
    def followers
      @client.user_followed_by me.id
    end
    
    def followings
      @client.user_follows me.id, count:1000
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
    
    def unfollow user_id
      @client.unfollow_user user_id
    end

    private
    
    def follow_count
      rand(12..MAX_FOLLOW_PER_SESSION)
    end
    
    def wait min=4
      sleep rand(min..20)
    end
    
    def session_wait
      sleep rand(60..1800)
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