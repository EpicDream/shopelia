require 'test_helper'

class ThemeTest < ActiveSupport::TestCase
  
  test "many to many associations for flinkers and hashtags" do
    theme = Theme.create!(title:"Fashion")
    assert theme.flinkers << [flinkers(:betty), flinkers(:fanny)]
    assert theme.hashtags << [Hashtag.new(name:'tag')]
    
    assert_equal 2, theme.reload.flinkers.count
    assert_equal 1, theme.hashtags.count
  end
  
  test "themes of given country + themes without country assigned" do
    theme_it = Theme.first
    theme_it.countries << countries(:italy)
    theme_es = Theme.last
    theme_es.countries << countries(:spain)
    theme_univ = Theme.limit(1).offset(1).first
    
    themes = Theme.for_country(countries(:italy))
    
    assert_equal 2, themes.count
    assert_equal [theme_univ.title, theme_it.title].to_set, themes.map(&:title).to_set
  end
  
end