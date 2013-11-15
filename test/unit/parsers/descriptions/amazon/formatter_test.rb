require 'test__helper'
require 'parsers/descriptions/amazon/formatter'

class Descriptions::Amazon::FormatterTest < ActiveSupport::TestCase
  #sandisk : http://www.amazon.fr/SanDisk-SDMX18-004G-E46K-Sansa-Lecteur-MicroSD/dp/B002NX0MF0
  #tigrou : http://www.amazon.fr/gp/product/B002MZZ2LI
  #les croods : http://www.amazon.fr/Croods-Kev-Adams/dp/B00CAUAA3U
  #tv lg : http://www.amazon.fr/LG-22EN33S-Ecran-1920-1080/dp/B00BBWLKQO
  #Window 8 : http://www.amazon.fr/Windows-Pro-OEM-64-bit-poste/dp/B00971Y91Y/ref=pd_sim_sw_3
  
  setup do
  end
  
  test "formatter detector detect ul-li type" do
    formatters = formatter_for('sandisk', 0).formatters
    
    assert_equal [Descriptions::Amazon::UlFormatter], formatters.map(&:class)
  end
  
  test "formatter detector detect tables type" do
    formatters = formatter_for('sandisk', 1).formatters
    expected = ["Table", "Text"].map { |name| "Descriptions::Amazon::#{name}Formatter".constantize }
    
    assert_equal expected.to_set, formatters.map(&:class).to_set
  end
  
  test "formatter detector detect ul, table, p types" do
    formatters = formatter_for('sandisk', 2).formatters
    
    expected = ["P", "Table", "Ul", "Text"].map { |name| "Descriptions::Amazon::#{name}Formatter".constantize }
    assert_equal expected.to_set, formatters.map(&:class).to_set
  end
  
  test "convert lis to array with lis text contents for sandisk sample" do
    representation = representation_for('sandisk', 0)
    content = representation["Header"]["Summary"].first

    assert_equal 5, content.count
    assert_equal "Garantie du fabricant: 1 an", content[0]
  end
  
  test "convert lis to array with lis text contents for tigrou sample" do
    representation = representation_for('tigrou', 0)
    
    content = representation["Header"]["Summary"].first

    assert_equal 5, content.count
    assert_equal "Age minimum: 2 ans", content[0]
  end
  
  test "convert simple tables to keys-values for sandisk sample" do
    representation = representation_for('sandisk', 1)
    descriptif = representation["Informations sur le produit"]["Descriptif technique"].first
    infos = representation["Informations sur le produit"]["Informations complémentaires"].first
    
    assert_equal 11, descriptif.keys.count
    assert_equal "SanDisk", descriptif["Marque"]
    assert_equal "Garantie Fabricant : 1 an", descriptif["Garantie constructeur"]
    assert_equal 4, infos.keys.count
    assert_equal "19 x 13 x 4 cm", infos["Dimensions du produit (L x l x h)"]
  end
  
  test "convert paragraphs, merge with same key" do
    representation = representation_for('sandisk', 2)
    content = representation["Descriptions du produit"]["Lecteurs MP3 SanDisk Sansa™ Clip+"]
    item = "Le petit lecteur MP3 portable qui offre un son de qualité ! Divertissez-vous davantage."
    
    assert_equal 3, content.count
    assert_equal item, content[1]
  end
  
  test "convert div with text at root" do
    representation = representation_for('tigrou', 2)
    descr = representation["Descriptions du produit"]["Descriptions du produit"]
    
    assert descr[1] =~ /^Déguisement.*?Disney/  
  end
  
  test "convert block with uls, p and tables. p inside table must be skipped" do
    representation = representation_for('sandisk', 2)
    foncs = representation["Descriptions du produit"]["Liste des fonctionnalités"].first
    expected_keys = ["Liste des fonctionnalités", "Configuration système minimale", "Contenu de l'emballage", "Lecteurs MP3 SanDisk Sansa™ Clip+", "Descriptions du produit"]

    assert_equal expected_keys.to_set, representation["Descriptions du produit"].keys.to_set
    assert_equal 9, foncs.count
    assert foncs.include?("Lecture des fichiers MP3, WMA, secure WMA, Audible, Ogg Vorbis et FLAC, ainsi que des livres audio et des podcasts")
  end
  
  test "complete product file sandisk" do
    html = description("sandisk")
    representation = Descriptions::Amazon::Formatter.format(html)
    infos = representation["Informations sur le produit"]["Descriptif technique"].first
    
    assert_equal representation.keys, ["Header", "Informations sur le produit", "Descriptions du produit"]
    assert_equal "SanDisk", infos["Marque"]
  end
  
  test "complete product file tigrou" do
    html = description("tigrou")
    representation = Descriptions::Amazon::Formatter.format(html)
    infos = representation["Informations sur le produit"]["Descriptif technique"].first
    
    assert_equal representation.keys, ["Header", "Informations sur le produit", "Descriptions du produit"]
    assert_equal "240 g", infos["Poids de l'article"]
  end
  
  test "complete product file windows8(c'est de la dobe)" do
    html = description("windows8")
    rep = Descriptions::Amazon::Formatter.format(html)

    assert_equal ["Microsoft", "Windows", "Pro", "Licence"], rep["Header"]["Summary"].first
    assert_equal rep["Détails sur le produit"]["Summary"].first[0], "Dimensions du produit:         13,8 x 19,2 x 0,2 cm ; 54 g"
  end
  
  test "complete product file les croods" do
    html = description("croods")
    rep = Descriptions::Amazon::Formatter.format(html)
    #puts JSON.pretty_generate(rep)
  end
  
  test "complete product file tv lg" do
    html = description("tvlg")
    rep = Descriptions::Amazon::Formatter.format(html)
    
    assert_equal ["LG Electronics", "22EN33S-B", "Écran", "LED"], rep["Header"]["Summary"].first
    assert_equal "50,9 x 18,1 x 38,7 cm", rep["Informations sur le produit"]["Descriptif technique"].first["Dimensions du produit (L x l x h)"]
  end
  
  private
  
  def description sample
    File.read("#{Rails.root}/test/fixtures/descriptions/#{sample}.html")
  end
  
  def formatter_for sample, index
    html = description(sample)
    blocks = html.split("<!-- SHOPELIA-END-BLOCK -->").delete_if { |block| block.blank? }
    Descriptions::Amazon::Formatter.new(blocks[index])
  end
  
  def representation_for sample, index
    formatter_for(sample, index).representation
  end
end