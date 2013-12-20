# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class StylebopComTest < ActiveSupport::TestCase

  setup do
    @helperClass = StylebopCom
    @url = "http://www.stylebop.com/fr/product_details.php?id=491539"
    @version = {}
    @helper = StylebopCom.new(@url)

    @canonize = {
      input: "http://www.stylebop.com/search/noproductsfound.php?id=157800&status=404",
      out: "http://www.stylebop.com/search/noproductsfound.php?status=404"
    }
    @availabilities = {
      "Recherche par:" => false,
      "Top Categories..." => false,
    }
  end

  include MerchantHelperTests
end
