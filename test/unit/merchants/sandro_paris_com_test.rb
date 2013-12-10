# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class SandroParisComTest < ActiveSupport::TestCase

  setup do
    @helperClass = SandroParisCom
    @url = "http://www.sandro-paris.com/eboutique-sandro/aw13/homme/jeans/jean-paint-blanc/produit-fiche,18,12,25,963629"
    @version = {}
    @helper = SandroParisCom.new(@url)

    @availabilities = {
    }

    @image_url = {
      input: "http://media-cache.sandro-paris.com/image/52/0/449520.72.jpg",
      out: "http://media-cache.sandro-paris.com/image/52/0/449520.jpg"
    }
    @images = {
      input: ["http://media-cache.sandro-paris.com/image/52/0/449520.96.jpg"],
      out: ["http://media-cache.sandro-paris.com/image/52/0/449520.jpg"]
    }
  end

  include MerchantHelperTests
end
