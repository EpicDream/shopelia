class ImenagerCom

  def initialize url
    @url = url
  end

  def canonize
    @url.gsub(/\?.*$/, "")
  end
end