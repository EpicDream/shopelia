# -*- encoding : utf-8 -*-
require 'test_helper'

class EveiletjeuxComTest < ActiveSupport::TestCase

  setup do
    @helper = EveiletjeuxCom.new("http://www.eveiletjeux.com/bac-a-sable-pop-up/produit/306367")
  end

  test "it should monetize" do
    assert_equal "http://ad.zanox.com/ppc/?25424162C654654636&ulp=[[http://logc57.xiti.com/gopc.url?xts=425426&xtor=AL-146-1%5Btypologie%5D-REMPLACE-%5Bparam%5D&xtloc=http://www.eveiletjeux.com/bac-a-sable-pop-up/produit/306367&url=http://www.eveiletjeux.com/Commun/Xiti_Redirect.htm]]", @helper.monetize
  end

  test "it should canonize" do
    assert_equal "http://www.eveiletjeux.com/bac-a-sable-pop-up/produit/306367", @helper.canonize
  end
end