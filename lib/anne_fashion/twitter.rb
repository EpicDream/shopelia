require 'twitter'
require 'bitly'

module AnneFashion
  class Twitter
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['twitter']
    MESSAGES = YAML.load_relative_file("messages.yml")
    HASHTAGS = ["#cute", "#cutie", "#fashion", "#fashionista", "#style", "#stylish", "#beauty", "#lindo", "#followback", "#pretty", "#girl", "#chic", "#look", "#lookbook", "#trend", "#trendy", "#outfit", "#lovethis", "#instafashion", "#luxury"]
    
    attr_reader :client
    
    def initialize
    end
    
    def publish
      bitly = Bitly.client
      look = Look.random(Look.published)
      image_path = "#{Rails.root}/public#{look.look_images.first.picture(:large)}"
      File.open(image_path, 'rb') { |f| File.open("/tmp/anne-fashion.jpg", 'wb') {|out| out.write(f.read) }}
      message = %Q{#{MESSAGES.sample} #{bitly.shorten(look.post.link).short_url} #{HASHTAGS.sample(3).join(" ")}}
      client.update_with_media(message, File.new("/tmp/anne-fashion.jpg"))
    end
    
    def twit message
      client.update(message)
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
    
    def follow_from_tweets query, max=20, retweet=false, favorite=false
      tweets = tweets(query)
      users_ids = tweets.map(&:user_mentions).flatten.map(&:id).uniq
      tweets_ids = tweets.map(&:id)
      follow(users_ids)
      retweet(tweets_ids) if retweet
      favorite(tweets_ids) if favorite
    end
    
    def follow users
      client.follow(users)
    end
    
    def client
      @client ||= ::Twitter::REST::Client.new do |config|
        [:consumer_key, :consumer_secret, :access_token, :access_token_secret].each { |key|  
          config.send("#{key}=", CREDENTIALS[key.to_s])
        }
      end
    end
    
  end
end
