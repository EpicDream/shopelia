# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class EbayFrTest < ActiveSupport::TestCase

  setup do
    @helperClass = EbayFr
    @url = "http://www.ebay.fr/itm/The-Big-Bang-Theory-Sheldon-Cooper-T-Rex-T-Shirt-/170725776688"
    @version = {}
    @helper = EbayFr.new(@url)

    @availabilities = {
      "Les enchères sur cet objet sont terminées. Le vendeur a remis en vente cet objet ou un objet similaire." => false,
    }
  end

  include MerchantHelperTests
end
