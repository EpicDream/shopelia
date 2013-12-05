# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class KookaiFrTest < ActiveSupport::TestCase

  setup do
    @helperClass = KookaiFr
    @url = "http://www.kookai.fr/fr/mode/e+boutique/pret-a-porter/Jupe/P-jupe_satin_de_soie_bijoux-132r2129.htm"
    @version = {}
    @helper = KookaiFr.new(@url)

    @availabilities = {
    }
    @canonize = {
      input: "http://www.kookai.fr/fr/mode/e+boutique/pret-a-porter/Jupe/P-jupe_satin_de_soie_bijoux-132r2129.htm?variantId=3603526411731(KookaiMasterCatalog)",
      out: "http://www.kookai.fr/fr/mode/e+boutique/pret-a-porter/Jupe/P-jupe_satin_de_soie_bijoux-132r2129.htm"
    }
    @image_url = [{
      input: "http://photo.kookai.fr/img/catalog/product/R2129-N3-F-1.jpg",
      out: "http://photo.kookai.fr/img/catalog/product/R2129-N3-Z-1.jpg"
    }, {
      input: "http://photo.kookai.fr/img/catalog/product/70722-KI-F-3.jpg",
      out: "http://photo.kookai.fr/img/catalog/product/70722-KI-Z-3.jpg"
    }]
    @images = {
      input: ["http://photo.kookai.fr/img/catalog/product/70722-KI-V-3.jpg"],
      out: ["http://photo.kookai.fr/img/catalog/product/70722-KI-Z-3.jpg"]
    }
  end

  include MerchantHelperTests
end
