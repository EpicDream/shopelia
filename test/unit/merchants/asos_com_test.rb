# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class AsosComTest < ActiveSupport::TestCase

  setup do
    @helperClass = AsosCom
    @version = {}
    @url = "http://us.asos.com/River-Island-Floral-Print-Smock-Dress/100geh/?Rf-400=12983&SearchQuery=dresssmock&clr=Blackfloral&iid=2929329&mk=na&mporgp=L1Byb2Qv&pge=0&pgesize=36&r=2&sh=0&sort=-1&xmk=na&xr=1"
    @helper = AsosCom.new(@url)

    @canonize = [
      {input: "http://us.asos.com/River-Island-Floral-Print-Smock-Dress/100geh/?Rf-400=12983&SearchQuery=dresssmock&clr=Blackfloral&iid=2929329&mk=na&mporgp=L1Byb2Qv&pge=0&pgesize=36&r=2&sh=0&sort=-1&xmk=na&xr=1",
       out: "http://us.asos.com/100geh/?iid=2929329"},
    ]
    @availability_text = [
    ]
    @availabilities = {
      "951 styles found" => false
    }
    @image_url = {
      input: "http://images.asos-media.com/inv/media/3/7/0/8/3158073/green/image1xl.jpg",
      out: "http://images.asos-media.com/inv/media/3/7/0/8/3158073/green/image1xxl.jpg"
    }
    @images = {
      input: ["http://images.asos-media.com/inv/media/3/7/0/8/3158073/image4s.jpg"],
      out: ["http://images.asos-media.com/inv/media/3/7/0/8/3158073/image4xxl.jpg"]
    }
  end

  include MerchantHelperTests
end
