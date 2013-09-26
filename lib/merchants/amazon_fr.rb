class AmazonFr

  def initialize url
    @url = url
  end

  def canonize
    if m = @url.match(/\/dp\/([A-Z0-9]+)/)
      "http://www.amazon.fr/dp/#{m[1]}"
    else
      nil
    end
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
