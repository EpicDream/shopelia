# -*- encoding : utf-8 -*-
require 'test_helper'

class CdiscountComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.cdiscount.com/electromenager/aspirateur-nettoyeur-vapeur/dirt-devil-m2828-3/f-110140405-dirtm28283.html"
    @helper = CdiscountCom.new(@url)
  end

  test "it should monetize" do
    assert_equal "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(765856165)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Felectromenager%2Faspirateur-nettoyeur-vapeur%2Fdirt-devil-m2828-3%2Ff-110140405-dirtm28283.html)", @helper.monetize
  end

  test "it should process availability" do
    @version[:availability_text] = "En stock"
    @version[:shipping_info] = "Sous 3 à 4 jours"
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]

    @version[:shipping_info] = "Disponible sous 6h en magasin"
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::UNAVAILABLE, @version[:availability_text]
  end

  test "it should canonize" do
    assert_equal "http://www.cdiscount.com/dp.asp?sku=81367657", CdiscountCom.new("http://www.cdiscount.com/dp.asp?sku=81367657").canonize
    assert_equal "http://www.cdiscount.com/dp.asp?sku=JAMO_S606HGB", CdiscountCom.new("http://www.cdiscount.com/dp.asp?sku=JAMO_S606HGB").canonize
  end

  test "it should process price shipping" do
    @version[:price_shipping_text] = ""
    @version = @helper.process_price_shipping(@version)
    assert_equal CdiscountCom::DEFAULT_PRICE_SHIPPING, @version[:price_shipping_text]

    @version[:price_shipping_text] = "4,90 €"
    @version = @helper.process_price_shipping(@version)
    assert_equal "4,90 €", @version[:price_shipping_text]
  end
end
