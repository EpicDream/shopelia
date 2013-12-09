# -*- encoding : utf-8 -*-
require 'test_helper'
require_relative './merchant_helper_tests'

class PimkieFrTest < ActiveSupport::TestCase

  setup do
    @helperClass = PimkieFr
    @url = "http://www.pimkie.fr/vestes-manteaux-femme/veste-habillee/veste-blanc-casse/912A09/p130484.html"
    @version = {}
    @helper = PimkieFr.new(@url)

    @availabilities = {
      "ACCUEIL > PARTY LOOK > PARTY LOOK (39)" => false,
    }
    @images = {
      input: ["http://www.pimkie.fr/img/FichesFichier/130596_1_vignette_323009_912A09_TH_1.JPG"],
      out: ["http://www.pimkie.fr/img/FichesFichier/130596_1_zoom_323009_912A09_HD_1.JPG"]
    }
    @options = [{
      level: 1,
      input: {"tagName"=>"SPAN","id"=>"","class"=>"color-display color-display-big","text"=>"","location"=>"http://www.pimkie.fr/pantalons-femme/short/short-fluide-a-carreaux-marine-et-rouge/899B03/p133890.html","title"=>"","style"=>"background-color:#0D0D0D;","xpath"=>"//div[@id=\"fp-bloc-descriptif-technique\"]/div/div[1]/ul/li/a/span","cssPath"=>"div#fp-bloc-descriptif-technique > div > div.color-part > ul > li > a > span","saturnPath"=>".color-part ul span","hash"=>"SPAN;;;http://www.pimkie.fr/pantalons-femme/short/short-fluide-a-carreaux-marine-et-rouge/899B03/p133890.html;;"},
      out: {"tagName"=>"SPAN","id"=>"","class"=>"color-display color-display-big","text"=>"#0D0D0D","location"=>"http://www.pimkie.fr/pantalons-femme/short/short-fluide-a-carreaux-marine-et-rouge/899B03/p133890.html","title"=>"","style"=>"background-color:#0D0D0D;","xpath"=>"//div[@id=\"fp-bloc-descriptif-technique\"]/div/div[1]/ul/li/a/span","cssPath"=>"div#fp-bloc-descriptif-technique > div > div.color-part > ul > li > a > span","saturnPath"=>".color-part ul span","hash"=>"SPAN;;;http://www.pimkie.fr/pantalons-femme/short/short-fluide-a-carreaux-marine-et-rouge/899B03/p133890.html;;"},
    }]
  end

  include MerchantHelperTests
end
