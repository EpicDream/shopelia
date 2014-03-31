require 'test_helper'

class ThemeSerializerTest < ActiveSupport::TestCase
  
  test "minimal serialization" do
    theme = themes(:mode)
    theme.send(:assign_default_cover)
    theme.countries << Country.first

    object = ThemeSerializer.new(theme).as_json[:theme]

    assert_equal [:title, :subtitle, :position, :cover_height, :cover, :country].to_set, object.keys.to_set
    assert_match "La mode c'est fun", object[:title]
    assert_match /http:\/\/www.flink.io\/images\/ae4\/large\/ae4fc89942443f7d5dda587fd1791ee7.jpg/, object[:cover]
    assert_equal Country.first.iso, object[:country]
  end
  
  test "maximal serialization, with hashtags, looks, flinkers" do
    
  end
  
end