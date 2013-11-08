# -*- encoding : utf-8 -*-

require 'rubygems'

module AlgoliaFeed

  class Tagger

    TAGS_HASH = 'algolia_tags'

    attr_accessor :redis

    def initialize(redis=nil)
      self.redis = redis || Redis.new
    end

    def self.build_from_redis(redis=nil)
      self.new(redis).build_from_redis
    end

    def build_from_redis
      # This method is called after several hours of cron work - PG connection is probably down
      ActiveRecord::Base.connection.reconnect!
      AlgoliaTag.delete_all
      self.redis.hkeys(TAGS_HASH).each do |key|
        kind, name = key.split(/\:/)
        count = self.redis.hget(TAGS_HASH, key).to_i
        next if count < 10
        name = name.squeeze(" ")
        AlgoliaTag.create(name:name, kind:kind, count:count) if name.length < 80
      end
    end

    def self.clear_redis(redis=nil)
      self.new(redis).clear_redis
    end

    def clear_redis
      self.redis.del(TAGS_HASH)
    end

    def increment(tag)
      n = self.redis.hget(TAGS_HASH, tag).to_i
      self.redis.hset(TAGS_HASH, tag, n + 1)
    end

  end
end

