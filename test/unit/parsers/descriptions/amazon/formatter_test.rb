require 'test__helper'
require 'parsers/descriptions/amazon/formatter'

class Descriptions::Amazon::FormatterTest < ActiveSupport::TestCase
  #sandisk : http://www.amazon.fr/SanDisk-SDMX18-004G-E46K-Sansa-Lecteur-MicroSD/dp/B002NX0MF0
  #tigrou : http://www.amazon.fr/gp/product/B002MZZ2LI
  
  setup do
  end
  
  test "formatter detector detect ul-li type" do
    formatter = formatter_for('sandisk_header')
    
    assert_equal Descriptions::Amazon::UlLiFormatter, formatter.node_formatter
  end
  
  test "convert lis to array with lis text contents for sandisk sample" do
    representation = representation_for('sandisk_header')
    
    assert_equal 5, representation[:summary].count
    assert_equal "Garantie du fabricant: 1 an", representation[:summary][0]
  end
  
  test "convert lis to array with lis text contents for tigrou sample" do
    representation = representation_for('tigrou_header')

    assert_equal 5, representation[:summary].count
    assert_equal "Age minimum: 2 ans", representation[:summary][0]
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
    formatter_for(sample).hash_representation
  end
end