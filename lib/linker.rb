class Linker

  def self.monetize url
    if url.blank?
      nil
    elsif url.match(/amazon/)
      self.amazon(url)
    else
      url
    end
  end
  
  private
  
  def self.amazon url
    if url.match(/tag=[a-z0-9\-]+/)
      url.gsub(/tag=[a-z0-9\-]+/, "tag=shopelia-21")
    elsif url.match(/\?/)
      url + "&tag=shopelia-21"
    else
      url + "?tag=shopelia-21"
    end
  end  

end
