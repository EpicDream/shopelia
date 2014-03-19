require 'test_helper'

class ThemeTest < ActiveSupport::TestCase
  
  test "many to many associations for flinkers and hashtags" do
    theme = Theme.create!(title:"Fashion")
    assert theme.flinkers << [flinkers(:betty), flinkers(:fanny)]
    assert theme.hashtags << [Hashtag.new(name:'tag')]
    
    assert_equal 2, theme.reload.flinkers.count
    assert_equal 1, theme.hashtags.count
  end
end