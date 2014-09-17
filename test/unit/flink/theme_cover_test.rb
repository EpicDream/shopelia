require 'test_helper'

class ThemeCoverTest < ActiveSupport::TestCase

  test "a cover image can be created without url" do
    theme = Theme.create!(title:"Fashion")
    
    cover = ThemeCover.new
    cover.picture = File.new("#{Rails.root}/app/assets/images/admin/default-cover.png")
    cover.theme = theme

    assert cover.save
  end
  
end