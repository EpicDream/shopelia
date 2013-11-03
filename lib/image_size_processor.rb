class ImageSizeProcessor

  PLIST = "imgurls_process_list"
  CACHE = "imgurls_size_cache"

  def initialize
    @redis = Redis.new
  end

  def process_last
    url = @redis.lpop PLIST
    size = FastImage.size(url)
    @redis.hset CACHE, url, size.join("x") unless size.nil?
    url
  end

  def get url
    size = @redis.hget CACHE, url
    @redis.lpush PLIST, url if size.nil?
    size
  end

  def self.process_all
    processor = ImageSizeProcessor.new
    count = 0
    begin
      url = processor.process_last
      count += 1
      puts "Processed #{count} urls" if count % 1000 == 0
    end while url.present?
    puts "Processed total #{count} urls"
  end
end