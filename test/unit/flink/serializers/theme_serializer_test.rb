require 'test_helper'

class ThemeSerializerTest < ActiveSupport::TestCase
  
  test "minimal serialization" do
    theme = themes(:mode)
    theme.send(:assign_default_cover)
    
    object = ThemeSerializer.new(theme).as_json[:theme]

    assert_equal [:title, :subtitle, :position, :cover_height, :cover].to_set, object.keys.to_set
    assert_match "La mode c'est fun", object[:title]
    assert_match /http:\/\/www.flink.io\/images\/ae4\/large\/ae4fc89942443f7d5dda587fd1791ee7.jpg/, object[:cover]
  end
  
end