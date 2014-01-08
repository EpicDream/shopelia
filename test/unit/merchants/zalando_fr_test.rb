# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class ZalandoFrTest < ActiveSupport::TestCase

  setup do
    @helperClass = ZalandoFr
    @url = "http://www.zalando.fr/desigual-winter-flowers-sac-a-main-multicolore-de151a05p-704.html"
    @version = {}
    @helper = ZalandoFr.new(@url)

    @availabilities = {
      "Vos modèles préférés" => false,
      "Plus de 1 500 marques" => false,
      "TOUS LES PRODUITS DE LA LEÇON DE STYLE:" => false,
      "Soldes d'hiver 2014 chez Zalando: (93 452 articles trouvés)" => false,
    }

    @image_url = {
      input: "http://i1.ztat.net/detail/LI/72/1C/05/59/16/LI721C055-916@1.1.jpg",
      out: "http://i1.ztat.net/large/LI/72/1C/05/59/16/LI721C055-916@1.1.jpg"
    }
    @images = {
      input:["http://i2.ztat.net/selector/LI/72/1C/05/59/16/LI721C055-916@4.1.jpg"],
      out: ["http://i2.ztat.net/large/LI/72/1C/05/59/16/LI721C055-916@4.1.jpg"]
    }
  end

  include MerchantHelperTests
end
