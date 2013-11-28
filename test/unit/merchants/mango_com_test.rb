# -*- encoding : utf-8 -*-
require 'test_helper'

class MangoComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://shop.mango.com/FR/p0/mango/vetements/?id=11060012_02"
    @helper = MangoCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(MangoCom)
  end

  test "it should monetize" do
  end

  test "it should canonize" do
  end

  test "it should process availability" do
    text = "Produit indisponible actuellement"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    # @version[:availability_text] = ""
    # @version = @helper.process_availability(@version)
    # assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should parse specific availability" do
  end

  test "it should process price_shipping unless if present" do
    @version[:price_shipping_text] = "3,50 €"
    @version = @helper.process_price_shipping(@version)
    assert_equal "3,50 €", @version[:price_shipping_text]
  end

  test "it should process price_shipping if empty" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal MangoCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]
  end

  test "it should process price_shipping if greater than limit" do
    @version[:price_shipping_text] = ""
    @version[:price_text] = sprintf("%.2f €", MangoCom::FREE_SHIPPING_LIMIT-1)
    @version = @helper.process_price_shipping(@version)
    assert_equal MangoCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_shipping_text] = "5.17 €"
    @version[:price_text] = sprintf("%.2f €", MangoCom::FREE_SHIPPING_LIMIT-1)
    @version = @helper.process_price_shipping(@version)
    assert_equal "5.17 €", @version[:price_shipping_text]

    @version[:price_shipping_text] = ""
    @version[:price_text] = sprintf("%.2f €", MangoCom::FREE_SHIPPING_LIMIT)
    @version = @helper.process_price_shipping(@version)
    assert_equal MerchantHelper::FREE_PRICE, @version[:price_shipping_text]
  end


  test "it should process shipping_info" do
    text = "Délai de 5 jours"
    @version[:shipping_info] = text
    @version = @helper.process_shipping_info(@version)
    assert_equal text, @version[:shipping_info]

    @version[:shipping_info] = ""
    @version = @helper.process_shipping_info(@version)
    assert_equal MangoCom::DEFAULT_SHIPPING_INFO, @version[:shipping_info]
  end

  test "it should process image_url" do
    @version[:image_url] = "http://st.mngbcn.com/rcs/pics/static/T1/fotos/S9/11060012_02.jpg"
    @version = @helper.process_image_url(@version)
    assert_equal "http://st.mngbcn.com/rcs/pics/static/T1/fotos/S20/11060012_02.jpg", @version[:image_url]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://st.mngbcn.com/rcs/pics/static/T1/fotos/S3/11060012_02.jpg"]
    @version = @helper.process_images(@version)
    assert_equal ["http://st.mngbcn.com/rcs/pics/static/T1/fotos/S20/11060012_02.jpg"], @version[:images]
  end
end
