require 'instagram'

module AnneFashion
  module InstagramRobotTasks
    MAX_FOLLOW_PER_SESSION = 40
    UNFOLLOW_COUNT_PER_SESSION = 20
    FRIENDS_FOLLOWERS_TO_FOLLOW_COUNT_PER_SESSION = 2
    
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
    
    def follow_friends_of_followers
      session_wait()
      followers.sample(follow_count()).each do |follower|
        friends = followers(follower.id).sample(FRIENDS_FOLLOWERS_TO_FOLLOW_COUNT_PER_SESSION) rescue [] #request unauthorized
        friends.each { |friend| follow friend.id; wait(min=10) }
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
      (followings.map(&:id) - followers.map(&:id)).sample(UNFOLLOW_COUNT_PER_SESSION)
    end
    
    def follow_count
      rand(12..MAX_FOLLOW_PER_SESSION)
    end
    
    def wait min=4
      sleep rand(min..20)
    end
    
    def session_wait
      sleep rand(60..1800)
    end
    
  end
  
  class Instagram
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['instagram']
    include InstagramRobotTasks
    
    attr_reader :client
    
    def initialize
      authenticate
      @client = ::Instagram::Client.new
    end
    
    def followers user_id=me.id
      all_pages(:user_followed_by, user_id)
    end
    
    def followings
      all_pages(:user_follows)
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
    
    def all_pages action, user_id=me.id
      next_cursor = nil
      users = []
      begin
        response = ::Instagram.send(action, user_id, {count:100, cursor:next_cursor})
        next_cursor = response.pagination.next_cursor
        users += response
      end while next_cursor
      users
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