# -*- encoding : utf-8 -*-
require 'test_helper'

class CarrefourFrTest < ActiveSupport::TestCase

  setup do
    @helper = CarrefourFr.new("http://online.carrefour.fr/electromenager-multimedia/hp/cartouche-encre-n-342-couleur_a00000318_frfr.html")
  end

  test "it should canonize" do
    assert_equal "http://online.carrefour.fr/electromenager-multimedia/hp/cartouche-encre-n-342-couleur_a00000318_frfr.html", @helper.canonize
  end
end