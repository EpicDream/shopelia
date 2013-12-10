# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class MajeComTest < ActiveSupport::TestCase

  setup do
    @helperClass = MajeCom
    @url = "http://fr.maje.com/fr/printemps-ete/robes/enigme/E14ENIGME.html?dwvar_E14ENIGME_color=2517#start=12&sz=12&srule=price-low-to-high"
    @version = {}
    @helper = MajeCom.new(@url)

    @availabilities = {
    }

    @image_url = {
      input: "http://demandware.edgesuite.net/sits_pod23/dw/image/v2/AAON_PRD/on/demandware.static/Sites-Maje-FR-Site/Sites-maje-catalog-master-H13/fr/v1386584327979/images/h13/Maje_E14ENIGME-2517_H_1.jpg?sw=460&sh=460&sm=fit",
      out: "http://demandware.edgesuite.net/sits_pod23/dw/image/v2/AAON_PRD/on/demandware.static/Sites-Maje-FR-Site/Sites-maje-catalog-master-H13/fr/v1386584327979/images/h13/Maje_E14ENIGME-2517_H_1.jpg"
    }
    @images = {
      input: ["http://demandware.edgesuite.net/sits_pod23/dw/image/v2/AAON_PRD/on/demandware.static/Sites-Maje-FR-Site/Sites-maje-catalog-master-H13/fr/v1386584327979/images/h13/Maje_E14ENIGME-2517_H_1.jpg?sw=150&sh=150&sm=fit"],
      out: ["http://demandware.edgesuite.net/sits_pod23/dw/image/v2/AAON_PRD/on/demandware.static/Sites-Maje-FR-Site/Sites-maje-catalog-master-H13/fr/v1386584327979/images/h13/Maje_E14ENIGME-2517_H_1.jpg"]
    }
  end

  include MerchantHelperTests
end
