# -*- encoding : utf-8 -*-
class AmazonCom

  def initialize url
    @url = url
  end

  def process_price version
    version[:price_text] = "0,00 €" if version[:price_text] == "Currently unavailable."
    version
  end
end