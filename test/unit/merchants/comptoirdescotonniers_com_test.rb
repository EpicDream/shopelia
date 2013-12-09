# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class ComptoirdescotonniersComTest < ActiveSupport::TestCase

  setup do
    @helperClass = ComptoirdescotonniersCom
    @url = "http://www.comptoirdescotonniers.com/eboutique/collection-femme/t-shirt/5659-palcinoe-couleur-noir-ref-palcinoe.html"
    @version = {}
    @helper = ComptoirdescotonniersCom.new(@url)

    @availabilities = {
    }
    @canonize = {
      input: "http://www.comptoirdescotonniers.com/eboutique/collection-femme/t-shirt/5615-palcinoe-couleur-rouge-ref-palcinoe.html?art_Id=20226",
      out: "http://www.comptoirdescotonniers.com/eboutique/collection-femme/t-shirt/5615-palcinoe-couleur-rouge-ref-palcinoe.html"
    }
    @images = {
      input: ["http://img.comptoirdescotonniers.com/pictures/article/42x42/14069.jpg"],
      out: ["http://img.comptoirdescotonniers.com/pictures/article/940x940/14069.jpg"]
    }
  end

  include MerchantHelperTests
end
