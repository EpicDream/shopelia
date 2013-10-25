# -*- encoding : utf-8 -*-
require 'test_helper'

class DartyComTest < ActiveSupport::TestCase

  setup do
    @helper = DartyCom.new("http://www.darty.com/nav/achat/gros_electromenager/refrigerateur_congelateur-refrigerateur-cong/refrigerateur_congelateur_bas/samsung_rl56gsbsw.html?bla")
  end

  test "it should monetize" do
    assert_equal "http://ad.zanox.com/ppc/?25424898C784334680&ulp=[[www.darty.com/nav/achat/gros_electromenager/refrigerateur_congelateur-refrigerateur-cong/refrigerateur_congelateur_bas/samsung_rl56gsbsw.html?dartycid=aff_zxpublisherid_lien-profond-libre_lientexte]]", @helper.monetize
  end

  test "it should canonize" do
    assert_equal "http://www.darty.com/nav/achat/gros_electromenager/refrigerateur_congelateur-refrigerateur-cong/refrigerateur_congelateur_bas/samsung_rl56gsbsw.html", @helper.canonize
  end
end