# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class SarenzaComTest < ActiveSupport::TestCase

  setup do
    @helperClass = SarenzaCom
    @version = {}
    @url = "http://www.sarenza.com/spot-on-torroi-s2139-p0000087628"
    @helper = SarenzaCom.new(@url)

    @availability_text = [
      {input: "36 - Dernière paire !", out: "Dernière paire !"},
    ]
    @availabilities = {
      "6643 MODÈLES" => false,
      "TOUTES LES MARQUES" => false,
    }
    @images = {
      input: ["http://azure.sarenza.net/static/_img/productsV4/0000061132/PI_0000061132_106887_09.jpg?201308250414"],
      out: ["http://azure.sarenza.net/static/_img/productsV4/0000061132/HD_0000061132_106887_09.jpg?201308250414"]
    }
  end

  include MerchantHelperTests
end
