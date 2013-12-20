# -*- encoding : utf-8 -*-
class AmazonCom < MerchantHelper
  def initialize(*)
    super

    @availabilities = {
      "Showing Top Results for" => false,
      /Showing \d+ - \d+ of \d+ Results/i => false,
    }
  end

  def process_price version
    # Bug, n'a pas sélectionné les options
    version[:availability_text] = MerchantHelper::UNAVAILABLE if version[:price_text] =~ /\$\d+(\.\d+)? - \$\d+(\.\d+)?/
    version
  end
end
