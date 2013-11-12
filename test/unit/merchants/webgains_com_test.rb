# -*- encoding : utf-8 -*-
require 'test_helper'

class WebgainsComTest < ActiveSupport::TestCase

  test "it should canonize" do
    urls = [
      { in: 'http://track.webgains.com/click.html?wgcampaignid=145659&wgprogramid=5236&product=1&wglinkid=233053&productname=Lovely+Argent+925+Blanc+boucle+d%27oreille+Femmes&wgtarget=http://www.milanoo.com/fr/Lovely-Argent-925-Blanc-boucle-doreille-Femmes-p50373.html',
        out: 'http://www.milanoo.com/fr/Lovely-Argent-925-Blanc-boucle-doreille-Femmes-p50373.html'
      }
    ]
    urls.each do |url|
      assert_equal(url[:out], WebgainsCom.new(url[:in]).canonize)
    end
  end
end
