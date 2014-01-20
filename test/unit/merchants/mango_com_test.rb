# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class MangoComTest < ActiveSupport::TestCase

  setup do
    @helperClass = MangoCom
    @url = "http://shop.mango.com/FR/p0/mango/vetements/?id=11060012_02"
    @version = {}
    @helper = MangoCom.new(@url)

    @availabilities = {
      "ORDER BY PRICE ASCENDING · DESCENDING" => false,
      "SORT BY PRICE ASCENDING · DESCENDING" => false,
    }


    @price_shipping_text = [{
      price_text: "29 €",
      out: @helper.default_price_shipping,
    },{
      price_text: "35 €",
      out: MerchantHelper::FREE_PRICE,
    }]
    @image_url = {
      input: "http://st.mngbcn.com/rcs/pics/static/T1/fotos/S9/11060012_02.jpg",
      out: "http://st.mngbcn.com/rcs/pics/static/T1/fotos/S20/11060012_02.jpg"
    }
    @images = {
      input:["http://st.mngbcn.com/rcs/pics/static/T1/fotos/S3/11060012_02.jpg"],
      out: ["http://st.mngbcn.com/rcs/pics/static/T1/fotos/S20/11060012_02.jpg"]
    }
  end

  include MerchantHelperTests
end
