require 'twitter'

module AnneFashion
  class Twitter
    CREDENTIALS = YAML.load_relative_file("accounts.yml")['twitter']
    attr_reader :client
    
    def initialize
    end
    
    def twit message
      client.update(message)
    end
    
    def search query, opts={}
      client.search(query, opts)
    end
    
    def retweet ids
      client.retweet ids
    end
    
    def favorite ids
      client.favorite(ids) rescue nil
    end
    
    def follow_from_tweet query, max=20, retweet=true, favorite=true
      users_ids = []
      tweets_ids = []
      results = search(query)
      while users_ids.count < max do
        tweets = results.select { |tweet| tweet.user_mentions.any? }
        users_ids += tweets.map(&:user_mentions).flatten.map(&:id)
        tweets_ids += tweets.map(&:id)
        break unless results.next_page?
        results = search(query, {max_id:results.next_page[:max_id]})
      end
      follow(users_ids)
      retweet(tweets_ids)
      favorite(tweets_ids)
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
