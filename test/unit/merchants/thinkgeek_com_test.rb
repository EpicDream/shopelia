# -*- encoding : utf-8 -*-
require 'test_helper'

class ThinkgeekComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.thinkgeek.com/product/c534/"
    @helper = ThinkgeekCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(ThinkgeekCom)
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

  test "it should process availability" do
    availabilities = {
      "In stock" => "In stock",
      "Out of stock" => "Out of stock",
      "" => "En stock",
      "future" => "Non disponible",
      "peter jackson-y" => "Non disponible",
      "on weekends only" => "Non disponible",
    }
    for avail, result in availabilities
      @version[:availability_text] = avail
      @version = @helper.process_availability(@version)
      assert_equal result, @version[:availability_text], "Fail to process '#{avail}'."
    end
  end


  test "it should process price" do
    @version[:price_text] = "N/A"
    @version = @helper.process_price(@version)
    assert_equal nil, @version[:price_text]

    @version[:price_text] = "3,90 €"
    @version = @helper.process_price(@version)
    assert_equal "3,90 €", @version[:price_text]
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_shipping_price(@version)
    assert_equal "27,50 $ (à titre indicatif)", @version[:price_shipping_text]
  end
end