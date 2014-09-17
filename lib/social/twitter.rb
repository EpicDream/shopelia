require 'twitter'
require 'bitly'

module AnneFashion
  class Twitter
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['twitter']
    HASHTAGS = ["#cute", "#cutie", "#fashion", "#fashionista", "#style", "#stylish", "#beauty", "#lindo", "#followback", "#pretty", "#girl", "#chic", "#look", "#lookbook", "#trend", "#trendy", "#outfit", "#lovethis", "#instafashion", "#luxury"]
    TMP_IMG_PATH = "/tmp/anne-fashion.jpg"
    PUBLIC_IMG_PATH = ->(look) { "#{Rails.root}/public#{look.look_images.first.picture(:large)}" }
    FOLLOWERS_RATIO = 0.9
    MAX_RETWEET = 2
    MAX_FAVORITE = 3
    MAX_FOLLOW_FROM_TWEETS = 20
    FOLLOW_TAGS = ["#lookbook", "#fashion", "#stylish"]
    DM_DISCOVER = "Just discovered this new app! Discover awesome looks from top fashion bloggers! https://itunes.apple.com/au/app/flink-discover-share-awesome/id798552697?mt=8&ign-mpt=uo%3D2"

    attr_reader :client
    
    def initialize
      @messages = YAML.load_relative_file("messages.yml")
      @bitly = Bitly.client
    end
    
    def publish n=3
      n.times do 
        begin
          message, media = fashion_post()
          client.update_with_media(message, media)
        rescue #140+
          attempts ||= 0
          retry if (attempts += 1) < 10
        end
      end
    end
    
    def fashion_post
      look = Look.random(Look.published)
      message = @messages.sample and @messages.delete(message)
      File.open(PUBLIC_IMG_PATH[look], 'rb') { |f| File.open(TMP_IMG_PATH, 'wb') {|out| out.write(f.read) }}
      message = %Q{#{message} #{@bitly.shorten(look.post.link).short_url} #{hashtags()}}
      [message, File.new(TMP_IMG_PATH)]
    end
    
    def twit message
      client.update(message)
    end
    
    def dm user_id, text
      message = client.create_direct_message(user_id, text)
      client.direct_message(message.id)
    end
    
    def search query, opts={}
      client.search(query, opts)
    end
    
    def tweets query, max=100
      results = search(query)
      tweets = []
      begin
        tweets += results.select { |tweet| tweet.user_mentions.any? }
        break unless results.next_page?
        results = search(query, {max_id:results.next_page[:max_id]})
      end while tweets.count < max
      tweets
    end
    
    def retweet ids
      client.retweet ids
    end
    
    def favorite ids
      client.favorite(ids) rescue nil
    end
    
    def follow_from_tweets query, max=MAX_FOLLOW_FROM_TWEETS, retweet=false, favorite=false
      session_wait()
      tweets = tweets(query)
      users_ids = tweets.map(&:user_mentions).flatten.map(&:id).uniq
      tweets_ids = tweets.map(&:id)
      follow(users_ids.sample(max))
      retweet(tweets_ids.sample(MAX_RETWEET)) if retweet
      favorite(tweets_ids.sample(MAX_FAVORITE)) if favorite
    end
    
    def friends
      followings = followings().to_a
      followers = followers().to_a
      followings & followers
    end
    
    def friends_of_friends
      followers(friends)
    end
    
    def follow_friends_of_friends n=20
      session_wait()
      follow friends_of_friends.to_a.sample(n)
    end
    
    def follow users
      client.follow(users)
    end
    
    def schedule_follow_ratio
      session_wait()
      followings = followings().to_a
      followers = followers().to_a
      unfollows = followings - followers
      
      ratio = followers.count / followings.count
      if ratio > FOLLOWERS_RATIO
        follow_from_tweets(FOLLOW_TAGS.sample, 20, maybe(), maybe())
      else
        unfollow(unfollows.sample(10))
        follow_from_tweets(FOLLOW_TAGS.sample, 10, maybe(), maybe())
      end
    end
    
    def followings
      client.following
    end
    
    def followers users=nil
      client.followers users
    end
    
    def unfollow users
      client.unfollow(users)
    end
    
    def client
      @client ||= ::Twitter::REST::Client.new do |config|
        [:consumer_key, :consumer_secret, :access_token, :access_token_secret].each { |key|  
          config.send("#{key}=", CREDENTIALS[key.to_s])
        }
      end
    end
    
    private
    
    def session_wait
      sleep rand(60..1800)
    end

    def maybe
      [true, false].sample
    end
    
    def hashtags n=3
      HASHTAGS.sample(n).join(" ")
    end
    
  end
end
