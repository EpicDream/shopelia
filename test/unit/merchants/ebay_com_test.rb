# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class EbayComTest < ActiveSupport::TestCase

  setup do
    @helperClass = EbayCom
    @url = "http://www.ebay.com/itm/Michael-Kors-Black-Sequin-Wrap-Cap-Sleeve-Dress-Size-Large-NWT-150-/231112612871?pt=US_CSA_WC_Dresses&hash=item35cf629c07"
    @version = {}
    @helper = EbayCom.new(@url)

    @availabilities = {
      "Bidding has ended on this item. The seller has relisted this item or one like this." => false,
      "This listing was ended by the seller because there was an error in the listing." => false,
      "This listing has ended." => false,
      "See all results" => false,
    }
  end

  include MerchantHelperTests
end
