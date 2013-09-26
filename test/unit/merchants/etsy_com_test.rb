# -*- encoding : utf-8 -*-
require 'test_helper'

class EtsyComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @helper = EtsyCom.new("http://www.etsy.com/fr/listing/151377819/childrens-teal-infinity-scarf-knit-kids?ref=hp_so_tr_10")
  end

  test "it should process shipping price (1)" do
    @version[:price_shipping_text] = "Europe hors UE  €4,56 EUR €3,04 EUR, Union européenne  €4,56 EUR €3,04 EUR, Autres pays €6,84 EUR €4,56 EUR"
    @version = @helper.process_shipping_price(@version)

    assert_equal "4,56", @version[:price_shipping_text]
  end

  test "it should process shipping price (2)" do
    @version[:price_shipping_text] = "Etats-Unis  €4,56 EUR €0,76 EUR, Canada  €6,08 EUR €1,52 EUR, Autres pays €11,40 EUR  €1,52 EUR"
    @version = @helper.process_shipping_price(@version)

    assert_equal "11,40", @version[:price_shipping_text]
  end  

  test "it should process shipping price (3)" do
    @version[:price_shipping_text] = "Etats-Unis  €4,56 EUR €0,76 EUR, Canada  €6,08 EUR €1,52 EUR"
    assert_difference "Incident.count", 1 do
      @version = @helper.process_shipping_price(@version)
    end

    assert_equal nil, @version[:price_shipping_text]
  end

  test "it should process shipping price (4)" do
    @version[:price_shipping_text] = "Etats-Unis  €4,56 EUR €0,76 EUR, France  €6,08 EUR €1,52 EUR, Autres pays €11,40 EUR  €1,52 EUR"
    @version = @helper.process_shipping_price(@version)

    assert_equal "6,08", @version[:price_shipping_text]
  end

  test "it should process shipping price (5)" do
    @version[:price_shipping_text] = "Non UE  €4,56 EUR €0,76 EUR, UE  €6,18 EUR €1,52 EUR, Autres pays €11,40 EUR  €1,52 EUR"
    @version = @helper.process_shipping_price(@version)

    assert_equal "6,18", @version[:price_shipping_text]
  end  

  test "it should process shipping price (6)" do
    @version[:price_shipping_text] = "UE  €4,56 EUR €0,76 EUR, Non UE  €6,18 EUR €1,52 EUR, Autres pays €11,40 EUR  €1,52 EUR"
    @version = @helper.process_shipping_price(@version)

    assert_equal "4,56", @version[:price_shipping_text]
  end  
end