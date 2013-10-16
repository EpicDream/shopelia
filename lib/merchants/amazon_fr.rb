class AmazonFr

  def initialize url
    @url = url
  end

  def process_availability version
    version[:availability_text] = "En stock" if version[:availability_text] =~ /Voir les offres de ces vendeurs/
    version[:availability_text] = "En stock" if version[:availability_text] =~ /plus que \d+ exemplaire/
    version
  end

  def canonize
    if m = @url.match(/\/dp\/([A-Z0-9]+)/)
      "http://www.amazon.fr/dp/#{m[1]}"
    elsif m = @url.match(/\/gp\/product\/([A-Z0-9]+)/)
      "http://www.amazon.fr/gp/product/#{m[1]}"
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
