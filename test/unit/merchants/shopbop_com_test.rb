# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class ShopbopComTest < ActiveSupport::TestCase

  setup do
    @helperClass = ShopbopCom
    @url = "http://www.shopbop.com/long-sleeve-earl-blouse-equipment/vp/v=1/1595511391.htm?folderID=2534374302025763&fm=other-shopbysize&colorId=55452"
    @version = {}
    @helper = ShopbopCom.new(@url)

    @canonize = {
      input: @url,
      out: "http://www.shopbop.com/long-sleeve-earl-blouse-equipment/vp/v=1/1595511391.htm"
    }
    @availabilities = {
      "2942 items" => false,
    }

    @price_shipping_text = [{
      price_text: "70 €",
      out: "10 €",
    },{
      price_text: "85 €",
      out: MerchantHelper::FREE_PRICE,
    }]

    @image_url = {
      input: "http://g-ecx.images-amazon.com/images/G/01/Shopbop/p/pcs/products/equip/equip4033611231/equip4033611231_q1_1-0_336x596.jpg",
      out: "http://g-ecx.images-amazon.com/images/G/01/Shopbop/p/pcs/products/equip/equip4033611231/equip4033611231_q1_1-0.jpg",
    }
    @images = {
      input: ["http://g-ecx.images-amazon.com/images/G/01/Shopbop/p/pcs/products/equip/equip4033611231/equip4033611231_q2_1-0_37x65.jpg"],
      out: ["http://g-ecx.images-amazon.com/images/G/01/Shopbop/p/pcs/products/equip/equip4033611231/equip4033611231_q2_1-0.jpg"],
    }
  end

  include MerchantHelperTests
end
