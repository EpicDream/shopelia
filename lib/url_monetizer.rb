class UrlMonetizer

  CACHE = "url_monetizer_cache"

  def initialize
    @redis = Redis.new
  end

  def get(canonized_url)
    original_url = @redis.hget(CACHE, canonized_url)
  end

  def set(canonized_url, original_url)
    @redis.hset(CACHE, canonized_url, original_url)
  end

  def del url
    @redis.del(CACHE, url)
  end
end
