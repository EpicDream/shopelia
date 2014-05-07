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
  
  test "titles for display" do
    theme = themes(:mode)

    assert_equal "La mode c'est fun", theme.title_for_display
    assert_equal "Carrément", theme.subtitle_for_display
  end
  
  test "english titles for display" do
    theme = themes(:mode)
    
    assert_equal "Fashion is fun", theme.title_for_display(:en)
    assert_equal "Really!", theme.subtitle_for_display(:en)
  end
  
  test "blank titles for display" do
    theme = themes(:mode)
    theme.update_attributes(en_title:"<styles></styles>")
    theme.update_attributes(en_subtitle:"<styles></styles>")
    
    assert theme.title_for_display(:en).blank?
    assert theme.subtitle_for_display(:en).blank?
  end
  
  test "on create theme series must be last series number" do
    assert_equal 0, themes(:mode).series
    themes(:mode).update_attributes(series:2)
    
    theme = Theme.create!(title:"Fashion")
    assert_equal 2, theme.series
  end
  
end