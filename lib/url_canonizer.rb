class UrlCanonizer

  CACHE = "url_canonizer_cache"

  def initialize
    @redis = Redis.new
  end

  def get url
    @redis.hget(CACHE, url)
  end

  def del url
    @redis.del(CACHE, url)
  end

  def set url, canonized_url
    @redis.hset(CACHE, url, canonized_url)
  end
end