# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class NikeComTest < ActiveSupport::TestCase

  setup do
    @helperClass = NikeCom
    @version = {}
    @url = "http://store.nike.com/fr/fr_fr/pd/air-max-2014-chaussure-course-a-pied/pid-805772/pgid-804079"
    @helper = NikeCom.new(@url)

    @availability_text = [
    ]
    @availabilities = {
      "23 ARTICLES" => false
    }
    @image_url = {
      input: "http://images.nike.com/is/image/emea/THN_PS/Nike-Air-Max-2014-Zapatillas-de-running---Hombre-621077_006_A.jpg?wid=620&fmt=jpg&qty=85&hei=620&bgc=F5F5F5",
      out: "http://images.nike.com/is/image/emea/THN_PS/Nike-Air-Max-2014-Zapatillas-de-running---Hombre-621077_006_A.jpg?wid=1860&fmt=jpg&qty=85&hei=1860&bgc=F5F5F5"
    }
    @images = {
      input: ["http://images.nike.com/is/image/emea/THN_PS/Nike-Air-Max-2014-Zapatillas-de-running---Hombre-621077_006_A.jpg?hei=60&wid=60&fmt=jpeg&bgc=F5F5F5"],
      out: ["http://images.nike.com/is/image/emea/THN_PS/Nike-Air-Max-2014-Zapatillas-de-running---Hombre-621077_006_A.jpg?hei=1860&wid=1860&fmt=jpeg&bgc=F5F5F5"]
    }
  end

  include MerchantHelperTests
end
