# -*- encoding : utf-8 -*-
require 'test_helper'

class TradedoublerComTest < ActiveSupport::TestCase

  test "it should canonize" do
    urls = [
      { in: 'http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(117232539)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3D3596971684129%26refer%3D*)',
        out: 'http://www.cdiscount.com/dp.asp?sku=3596971684129'
      },
      { in: "http://pdt.tradedoubler.com/click?a(2056816)p(3436)prod(1182483695)ttid(5)url(http%3A%2F%2Fwww.yoox.com%2Fitem.asp%3Fcod10%3D35187059%26tp%3D14681%26utm_source%3Dtradedoubler_fr%26utm_medium%3Daffiliazione%26utm_campaign%3Daffiliazione_fr%26tskay%3D2FA4E164)",
        out: nil
      }
    ]
    urls.each do |url|
      assert_equal(url[:out], TradedoublerCom.new(url[:in]).canonize)
    end
  end
end