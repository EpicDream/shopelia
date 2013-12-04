class ShopstyleCom

  def initialize url
    @url = url
  end

  def canonize
    if matches = /&url=(.*)\Z/.match(@url)
      return Linker.decode(matches[1]) 
    end
    nil
  end
end