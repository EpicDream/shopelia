class AmazonFr

  def initialize url
    @url = url
  end

  def monetize
    if @url.match(/tag=[a-z0-9\-]+/)
      @url.gsub(/tag=[a-z0-9\-]+/, "tag=shopelia-21")
    elsif @url.match(/\?/)
      @url + "&tag=shopelia-21"
    else
      @url + "?tag=shopelia-21"
    end
  end

end
