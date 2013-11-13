require 'test__helper'
require 'parsers/descriptions/amazon/formatter'

class Descriptions::Amazon::FormatterTest < ActiveSupport::TestCase
  #sandisk : http://www.amazon.fr/SanDisk-SDMX18-004G-E46K-Sansa-Lecteur-MicroSD/dp/B002NX0MF0
  
  setup do
  end
  
  test "formatter detector detect ul-li type" do
    formatter = formatter_for('sandisk_header')
    
    assert_equal Descriptions::Amazon::UlLiFormatter, formatter.node_formatter
  end
  
  test "convert lis to array with lis text contents" do
    formatter = formatter_for('sandisk_header')
    
    hash = formatter.hash_representation
    representation = hash[:summary]
    
    assert_equal 5, representation.count
    assert_equal "Garantie du fabricant: 1 an", representation[0]
  end
  
  private
  
  def description sample
    File.read("#{Rails.root}/test/fixtures/descriptions/#{sample}.html")
  end
  
  def formatter_for sample
    html = description(sample)
    Descriptions::Amazon::Formatter.new(html)
  end
end