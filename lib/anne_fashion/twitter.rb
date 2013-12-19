require 'twitter'

module AnneFashion
  class Twitter
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['twitter']
    MESSAGES = YAML.load_relative_file("messages.yml")
    
    attr_reader :client
    
    def initialize
    end
    
    def publish
      look = Look.random
      image_path = "#{Rails.root}/public#{look.look_images.first.picture(:large)}"
      file = File.open(image_path, 'rb') do |f|
        File.open("/tmp/anne-fashion.jpg", 'wb') {|out| out.write(f.read) }
      end
      message = %Q{#{MESSAGES.sample} #{look.post.link}}
      client.update_with_media(message, file)
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
        results = search(query, {max_id:results.next_page[:max_id]})
      end while tweets.count < max && results.next_page?
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
