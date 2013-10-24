# -*- encoding : utf-8 -*-
require 'test_helper'

class PriceministerComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.priceminister.com/offer/buy/103220572"
    @helper = PriceministerCom.new(@url)
  end

  test "it should monetize" do
    assert_equal "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html", PriceministerCom.new("http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html#sort=0&filter=10&s2m_exaffid=977275").monetize
  end

  test "it should canonize" do
    urls = [
      { in: "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html#sort=0&filter=10&s2m_exaffid=977275",
        out: "http://www.priceminister.com/offer/buy/103220572"
      },
      { in: "http://track.effiliation.com/servlet/effi.redir?id_compteur=ID_COMPTEUR&url=http://www.priceminister.com/offer/buy/201441969/sort1/filter10/sort1%3Ft%3DTRACKING_CODE",
        out: "http://www.priceminister.com/offer/buy/201441969"
      }
    ]
    urls.each do |url|
      assert_equal(url[:out], PriceministerCom.new(url[:in]).canonize)
    end
  end

  test "it should process availability" do
    text = "Voir les offres de ces vendeurs"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal "En stock", @version[:availability_text]
  end
end
