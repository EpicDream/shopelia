# -*- encoding : utf-8 -*-
require 'test_helper'

class PublicideesComTest < ActiveSupport::TestCase

  test "it should canonize" do
    urls = [
      { in: 'http://tracking.publicidees.com/clic.php?partid=37027&amp;progid=1812&amp;adfactory_type=12&amp;idfluxpi=352&amp;url=http%3A%2F%2Fwww.jennyfer.com%2Ffr%2Flot-de-2-paires-de-collants-noirs.html',
        out: 'http://www.jennyfer.com/fr/lot-de-2-paires-de-collants-noirs.html'
      }
    ]
    urls.each do |url|
      assert_equal(url[:out], PublicideesCom.new(url[:in]).canonize)
    end
  end
end
