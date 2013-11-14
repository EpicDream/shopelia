require 'test__helper'
require 'parsers/descriptions/amazon/formatter'

class Descriptions::Amazon::FormatterTest < ActiveSupport::TestCase
  #sandisk : http://www.amazon.fr/SanDisk-SDMX18-004G-E46K-Sansa-Lecteur-MicroSD/dp/B002NX0MF0
  #tigrou : http://www.amazon.fr/gp/product/B002MZZ2LI
  #les croods : http://www.amazon.fr/Croods-Kev-Adams/dp/B00CAUAA3U
  #tv lg : http://www.amazon.fr/LG-22EN33S-Ecran-1920-1080/dp/B00BBWLKQO
  
  setup do
  end
  
  test "formatter detector detect ul-li type" do
    formatters = formatter_for('sandisk_header').formatters
    
    assert_equal [Descriptions::Amazon::UlFormatter], formatters.map(&:class)
  end
  
  test "formatter detector detect tables type" do
    formatters = formatter_for('sandisk_descriptif').formatters
    
    assert_equal [Descriptions::Amazon::TableFormatter]*2, formatters.map(&:class)
  end
  
  test "formatter detector detect ul, table, p types" do
    formatters = formatter_for('sandisk_descriptions').formatters
    
    expected = ["P", "Table", "Ul"].map { |name| "Descriptions::Amazon::#{name}Formatter".constantize }
    assert_equal expected.to_set, formatters.map(&:class).to_set
  end
  
  test "convert lis to array with lis text contents for sandisk sample" do
    representation = representation_for('sandisk_header')
    content = representation["Header"]["Summary"].first
    
    assert_equal 5, content.count
    assert_equal "Garantie du fabricant: 1 an", content[0]
  end
  
  test "convert lis to array with lis text contents for tigrou sample" do
    representation = representation_for('tigrou_header')
    
    content = representation["Header"]["Summary"].first

    assert_equal 5, content.count
    assert_equal "Age minimum: 2 ans", content[0]
  end
  
  test "convert simple tables to keys-values for sandisk sample" do
    representation = representation_for('sandisk_descriptif')
    descriptif = representation["Informations sur le produit"]["Descriptif technique"].first
    infos = representation["Informations sur le produit"]["Informations complémentaires"].first
    
    assert_equal 11, descriptif.keys.count
    assert_equal "SanDisk", descriptif["Marque"]
    assert_equal "Garantie Fabricant : 1 an", descriptif["Garantie constructeur"]
    assert_equal 4, infos.keys.count
    assert_equal "19 x 13 x 4 cm", infos["Dimensions du produit (L x l x h)"]
  end
  
  test "convert paragraphs, merge with same key" do
    representation = representation_for('sandisk_paragraphs')
    content = representation["Descriptions du produit"]["Lecteurs MP3 SanDisk Sansa™ Clip+"]
    item = "Le petit lecteur MP3 portable qui offre un son de qualité ! Divertissez-vous davantage."
    
    assert_equal 1, representation["Descriptions du produit"].keys.count
    assert_equal 3, content.count
    assert_equal item, content[1]
  end
  
  test "convert block with uls, p and tables. p inside table must be skipped" do
    representation = representation_for('sandisk_descriptions')
    table = representation["Descriptions du produit"]["Matrice de capacité de lecture"].first
    foncs = representation["Descriptions du produit"]["Liste des fonctionnalités"].first

    expected_keys = ["Matrice de capacité de lecture", "Liste des fonctionnalités", "Configuration système minimale", "Contenu de l'emballage", "Lecteurs MP3 SanDisk Sansa™ Clip+"]

    assert_equal expected_keys.to_set, representation["Descriptions du produit"].keys.to_set
    assert table =~ /^<table/
    assert_equal 9, foncs.count
    assert foncs.include?("Batterie longue durée rechargeable offrant jusqu'à 15 heures† d'écoute en continu ")
  end
  
  private
  
  def description sample
    File.read("#{Rails.root}/test/fixtures/descriptions/#{sample}.html")
  end
  
  def formatter_for sample
    html = description(sample)
    Descriptions::Amazon::Formatter.new(html)
  end
  
  def representation_for sample
    formatter_for(sample).representation
  end
end