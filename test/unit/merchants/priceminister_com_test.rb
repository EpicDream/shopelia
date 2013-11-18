# -*- encoding : utf-8 -*-
require 'test_helper'

class PriceministerComTest < ActiveSupport::TestCase

  setup do
    @version = {}
    @url = "http://www.priceminister.com/offer/buy/103220572"
    @helper = PriceministerCom.new(@url)
  end

  test "it should find class from url" do
    assert MerchantHelper.send(:from_url, @url).kind_of?(PriceministerCom)
  end

  test "it should monetize" do
    assert_equal "http://track.effiliation.com/servlet/effi.redir?id_compteur=12712494&url=http%3A%2F%2Fwww.priceminister.com%2Foffer%2Fbuy%2F103220572", @helper.monetize
  end

  test "it should canonize" do
    urls = [
      { in: "http://www.priceminister.com/offer/buy/103220572/hub-4-ports-usb-avec-rechauffeur-de-tasse-spyker-accessoire.html#sort=0&filter=10&s2m_exaffid=977275",
        out: "http://www.priceminister.com/offer/buy/103220572"
      },
      { in: "http://track.effiliation.com/servlet/effi.redir?id_compteur=ID_COMPTEUR&url=http://www.priceminister.com/offer/buy/201441969/sort1/filter10/sort1%3Ft%3DTRACKING_CODE",
        out: "http://www.priceminister.com/offer/buy/201441969"
      }
    ]
    urls.each do |url|
      assert_equal(url[:out], PriceministerCom.new(url[:in]).canonize)
    end
  end

  test "it should process availability" do
    text = "Voir les offres de ces vendeurs"
    @version[:availability_text] = text
    @version = @helper.process_availability(@version)
    assert_equal text, @version[:availability_text]

    @version[:availability_text] = ""
    @version = @helper.process_availability(@version)
    assert_equal MerchantHelper::AVAILABLE, @version[:availability_text]
  end

  test "it should parse specific availability" do
    assert_equal false, MerchantHelper.parse_availability("1 résultat", @url)
    assert_equal false, MerchantHelper.parse_availability("15 résultats", @url)
    assert_equal false, MerchantHelper.parse_availability("1\u00a0252\u00a0 resultats", @url)
    assert_equal false, MerchantHelper.parse_availability("Aucun résultat ne correspond à votre recherche", @url)

    assert_equal false, MerchantHelper.parse_availability("Top Ventes", @url)
    assert_equal true, MerchantHelper.parse_availability("Les produits les plus vus du moment dans 'Vêtements femme'", @url)
    assert_equal true, MerchantHelper.parse_availability("Les PriceMembers ayant vu 'Moteur De Tournebroche À Pile Pour Barbecue' ont également vu", @url)
  end

  test "it should process image_url ajaxLoader" do
    @version[:image_url] = "http://pmcdn.priceminister.com/photo/apple-iphone-4-16gb-telephone-intelligent-smartphone-mobile-947746009_ML.jpg"
    @version = @helper.process_image_url(@version)
    assert_equal "http://pmcdn.priceminister.com/photo/apple-iphone-4-16gb-telephone-intelligent-smartphone-mobile-947746009.jpg", @version[:image_url]
  end

  test "it should process images" do
    @version[:images] = nil
    @version = @helper.process_images(@version)
    assert_nil @version[:images]

    @version[:images] = []
    @version = @helper.process_images(@version)
    assert_equal [], @version[:images]

    @version[:images] = ["http://pmcdn.priceminister.com/photo/947746009_XS.jpg"]
    @version = @helper.process_images(@version)
    assert_equal ["http://pmcdn.priceminister.com/photo/947746009.jpg"], @version[:images]
  end
end
