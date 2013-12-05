# -*- encoding : utf-8 -*-
require 'test_helper'

class AsosFrTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.asos.fr/Huf-Haze-Casquette-0-empi%C3%A8cements-%C3%A0-motif/11nkdu/?iid=2979339&cid=6517&sh=0&pge=0&pgesize=36&sort=-1&clr=Black&mporgp=L0h1Zi9IdWYtSGF6ZS1QYXR0ZXJuLTUtUGFuZWwtQ2FwL1Byb2Qv"
    @helper = AsosFr.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(AsosFr)
  end

  test "it should monetize" do
  end

  test "it should canonize" do
    urls = [
      { in: "http://www.asos.fr/Huf-Haze-Casquette-0-empi%C3%A8cements-à-motif/11nkdu/?iid=2979339&cid=6517&sh=0&pge=0&pgesize=36&sort=-1&clr=Black&mporgp=L0h1Zi9IdWYtSGF6ZS1QYXR0ZXJuLTUtUGFuZWwtQ2FwL1Byb2Qv",
        out: "http://www.asos.fr/11nkdu/?iid=2979339" },
      { in: "http://www.asos.fr/ASOS-Pull-%C3%A0-motif-color-block/115g23/?iid=3158073&cid=16844&sh=0&pge=0&pgesize=36&sort=-1&clr=Green&r=2&mporgp=L0FTT1MvQVNPUy1KdW1wZXItSW4tQmxvY2tlZC1QYXR0ZXJuL1Byb2Qv",
        out: "http://www.asos.fr/115g23/?iid=3158073" },
      { in: "http://www.asos.fr/The-Kooples-Sport-D%c3%a9bardeur-zipp%c3%a9/1105ev/?iid=3301498&mporgp=L1Byb2Qv&r=2",
        out: "http://www.asos.fr/1105ev/?iid=3301498" },
      { in: "http://www.asos.fr/Homme-Costumes-et-blazers/y1bah/?cid=5678",
        out: "http://www.asos.fr/Homme-Costumes-et-blazers/y1bah/?cid=5678" },
      { in: "http://www.asos.fr/Prod/pgeproduct.aspx?iid=2306336&r=2",
        out: "http://www.asos.fr/Prod/pgeproduct.aspx?iid=2306336" },
      { in: "http://www.asos.fr/American-Apparel-Sweat-molletonn--manches-raglan/10oltu/?Rf-200=16&Rf998=4087&WT.tsrc=Affiliate&affId=2439&clr=Grey&iid=3112995%3Fcid%3D11321&mporgp=L0FtZXJpY2FuLUFwcGFyZWwvQW1lcmljYW4tQXBwYXJlbC1GbGVlY2UtUmFnbGFuLVN3ZWF0LVRvcC9Qcm9kLw..&pge=1&pgesize=36&r=2&sh=0&sort=-1&stop_mobi=yes",
        out: "http://www.asos.fr/10oltu/?iid=3112995"}
    ]
    urls.each do |url|
      assert_equal(url[:out], AsosFr.new(url[:in]).canonize)
    end
  end

  test "it should process availability" do
    text = "Produit indisponible actuellement"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("1-36 of 4225View 204 per page", @url)[:avail]
    assert_equal false, MerchantHelper.parse_availability("23 style(s) trouvé(s)", @url)[:avail]
  end

  test "it should process price_shipping" do
    text = "Supplément de 5 €"
    @version[:price_shipping_text] = text
    @version = @helper.process_price_shipping(@version)
    assert_equal text, @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal AsosFr::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process shipping_info" do
    text = "Délai de 5 jours"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal text, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal AsosFr::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process image_url" do
    @version[:image_url] = "http://images.asos-media.com/inv/media/3/7/0/8/3158073/green/image1xl.jpg"
    @version = @helper.process_image_url(@version)
    assert_equal "http://images.asos-media.com/inv/media/3/7/0/8/3158073/green/image1xxl.jpg", @version[:image_url]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://images.asos-media.com/inv/media/3/7/0/8/3158073/image4s.jpg"]
    @version = @helper.process_images(@version)
    assert_equal ["http://images.asos-media.com/inv/media/3/7/0/8/3158073/image4xxl.jpg"], @version[:images]
  end
end
