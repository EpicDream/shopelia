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
  rescue
  end

  def get url
    size = @redis.hget CACHE, url
    @redis.lpush PLIST, url if size.nil?
    size
  end

  def self.process_all
    processor = ImageSizeProcessor.new
    begin
      url = processor.process_last
    end while url.present?
  end

  def self.get_image_size url, retry_fetch=true
    return unless url =~ /^http/
    size = FastImage.size(url, :raise_on_failure=>true)
    size.join("x") unless size.nil?
  rescue 
    return unless retry_fetch
    `curl #{url} > /dev/null 2>&1`
    self.get_image_size(url, false)
  end    
end