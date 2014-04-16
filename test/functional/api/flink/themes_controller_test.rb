require 'test_helper'

class Api::Flink::ThemesControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @fanny = flinkers(:fanny)
    sign_in @fanny
    Theme.all.each { |theme| 
      theme.send(:assign_default_cover)
    }
  end

  test "get themes published with minimal informations" do
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    
    assert_equal 2, themes.count
    assert_equal [themes(:mode).title, themes(:sexy).title].to_set, themes.map{ |t| t["title"] }.to_set
  end
  
  test "get theme detail" do
    theme = Theme.first
    theme.looks << Look.first(3)
    theme.flinkers << Flinker.first(2)
    
    get :show, format: :json, id:theme.id
    
    assert_response :success
    
    theme = json_response["theme"]

    assert_equal 3, theme["looks"].count
    assert_equal 2, theme["flinkers"].count
  end
  
  test "get themes pre published only if current flinker device is dev" do
    @fanny.device.update_attributes(is_dev:true)
    
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    
    assert_equal 3, themes.count
    assert_equal Theme.all.map(&:title).to_set, themes.map{ |t| t["title"] }.to_set
  end
  
  test "get theme for specific country" do
    Theme.all.each { |theme| 
      theme.countries << countries(:france)
    }
    
    theme = Theme.first
    theme.countries << countries(:italy)
    theme.save!
    @fanny.country = countries(:italy)
    @fanny.save!
    
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    assert_equal 1, themes.count
    assert_equal theme.title, themes.first["title"]
  end
  
  test "get theme with titles in english if flinker is not french lang" do
    @fanny.update_attributes(lang_iso:'de_DE')
    
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    
    assert_equal 2, themes.count
    assert_equal [themes(:mode).en_title, themes(:sexy).en_title].to_set, themes.map{ |t| t["title"] }.to_set
  end

end