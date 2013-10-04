# -*- encoding : utf-8 -*-
class AmazonCom

  def initialize url
    @url = url
  end

  def process_availability version
    version[:availability_text] = "Non disponible" if version[:availability_text] =~ /\$\d+(\.\d+)? - \$\d+(\.\d+)?/
    version
  end

  def process_price version
    version[:price_text] = "0,00 €" if version[:price_text] == "Currently unavailable."
    version
  end
end