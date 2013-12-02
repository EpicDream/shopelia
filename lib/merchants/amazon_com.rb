# -*- encoding : utf-8 -*-
class AmazonCom

  def initialize url
    @url = url
  end

  def process_price version
    # Bug, n'a pas sélectionné les options
    version[:availability_text] = MerchantHelper::UNAVAILABLE if version[:price_text] =~ /\$\d+(\.\d+)? - \$\d+(\.\d+)?/
    version
  end
end