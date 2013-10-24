# -*- encoding : utf-8 -*-
require 'test_helper'

class EffiliationComTest < ActiveSupport::TestCase

  test "it should canonize" do
    urls = [
      { in: "http://track.effiliation.com/servlet/effi.redir?id_compteur=ID_COMPTEUR&url=http://www.priceminister.com/offer/buy/201441969/sort1/filter10/sort1%3Ft%3DTRACKING_CODE",
        out: "http://www.priceminister.com/offer/buy/201441969"
      }
    ]
    urls.each do |url|
      assert_equal(url[:out], EffiliationCom.new(url[:in]).canonize)
    end
  end

end
