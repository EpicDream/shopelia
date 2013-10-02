# -*- encoding : utf-8 -*-
require 'test_helper'

class ThinkgeekComTest < ActiveSupport::TestCase

  test "it should find class from url" do
    url = "http://www.thinkgeek.com/product/f285/"
    assert MerchantHelper.send(:from_url, url).kind_of?(ThinkgeekCom)
  end

  test "it should canonize" do
    urls = {
      "http://www.thinkgeek.com/geektoys/plush/?icpg=gy_ebc5" => nil,
      "http://www.thinkgeek.com/product/c534/" => "http://www.thinkgeek.com/product/c534/",
      "http://www.thinkgeek.com/stuff/looflirpa/bobafett.shtml" =>
        "http://www.thinkgeek.com/stuff/looflirpa/bobafett.shtml",
      "http://www.thinkgeek.com/product/f285/?CJID=2617611&CJURL=&cpg=cj&ref=" =>
        "http://www.thinkgeek.com/product/f285/",
    }
    for url, result in urls
      assert_equal result, ThinkgeekCom.new(url).canonize
    end
  end

  test "it should process price shipping" do
    version = {price_shipping_text: ""}
    version = ThinkgeekCom.new("http://www.thinkgeek.com/product/f285/").process_shipping_price(version)

    assert_equal "27,50 $ (à titre indicatif)", version[:price_shipping_text]
  end
end