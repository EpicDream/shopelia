# -*- encoding : utf-8 -*-
require 'test_helper'

class FnacComTest < ActiveSupport::TestCase

  setup do
    @helper = FnacCom.new("http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4#bl=MMtvh")
  end

  test "it should monetize" do
    assert_equal "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[www.fnac.com%2FTous-les-Enregistreurs%2FEnregistreur-DVD-Enregistreur-Blu-ray%2Fnsh180760%2Fw-4%23bl%3DMMtvh]]", @helper.monetize
  end

  test "it should canonize" do
    assert_equal "http://www.fnac.com/Tous-les-Enregistreurs/Enregistreur-DVD-Enregistreur-Blu-ray/nsh180760/w-4", @helper.canonize
  end
end