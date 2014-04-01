require 'test_helper'

class ThemeSerializerTest < ActiveSupport::TestCase
  ATTRIBUTES = [:id, :title, :subtitle, :position, :cover_height, :cover_large, :cover_small, :country]
  FULL_ATTRIBUTES = ATTRIBUTES + [:looks, :flinkers]
  
  setup do
    @theme = themes(:mode)
    @theme.send(:assign_default_cover)
    @theme.countries << Country.first
  end
  
  test "minimal serialization" do
    object = ThemeSerializer.new(@theme).as_json[:theme]

    assert_equal ATTRIBUTES.to_set, object.keys.to_set
    assert_match "La mode c'est fun", object[:title]
    assert_match /http:\/\/www.flink.io\/images\/ae4\/large\/ae4fc89942443f7d5dda587fd1791ee7.jpg/, object[:cover_large]
    assert_match /http:\/\/www.flink.io\/images\/ae4\/pico\/ae4fc89942443f7d5dda587fd1791ee7.jpg/, object[:cover_small]
    assert_equal Country.first.iso, object[:country]
    assert_equal @theme.id, object[:id]
  end
  
  test "maximal serialization, with hashtags, looks, flinkers" do
    @theme.looks << Look.first(3)
    @theme.flinkers << Flinker.first(2)
    object = ThemeSerializer.new(@theme, scope:{full:true}).as_json[:theme]
    
    assert_equal FULL_ATTRIBUTES.to_set, object.keys.to_set
    assert_equal 3, object[:looks].count
    assert_equal 2, object[:flinkers].count
  end
  
end