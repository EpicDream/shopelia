require 'test_helper'

class Api::Flink::ThemesControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @fanny = flinkers(:fanny)
    Theme.all.each { |theme| 
      theme.send(:assign_default_cover)
    }
    @request.env["X-Flink-User-Language"] = "fr_FR"
    set_env_user_agent(36)
  end

  test "get themes published with minimal informations" do
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    
    assert_equal 2, themes.count
    assert_equal [themes(:mode).title, themes(:sexy).title].to_set, themes.map{ |t| t["title"] }.to_set
  end
  
  test "get theme detail" do
    sign_in @fanny
    
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
    sign_in @fanny
    @fanny.device.update_attributes(is_dev:true)
    
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    
    assert_equal 3, themes.count
    assert_equal Theme.all.map(&:title).to_set, themes.map{ |t| t["title"] }.to_set
  end
  
  test "get theme for specific country" do
    sign_in @fanny
    @request.env["X-Flink-Country-Iso"] = "IT"
    
    Theme.all.each { |theme| 
      theme.countries << countries(:france)
    }
    
    theme = Theme.first
    theme.countries << countries(:italy)
    theme.save!
    
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    assert_equal 1, themes.count
    assert_equal theme.title, themes.first["title"]
  end
  
  test "get theme with titles in english if flinker is not french lang" do
    @request.env["X-Flink-User-Language"] = "de_DE"
    
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    
    assert_equal 2, themes.count
    assert_equal [themes(:mode).en_title, themes(:sexy).en_title].to_set, themes.map{ |t| t["title"] }.to_set
  end
  
  test "convert fonts if build < 36" do
    set_env_user_agent(35)
    themes(:sexy).destroy
    themes(:mode).update_attributes(title: "<styles><style font='CooperBlackStd' size='24'>Sexy girls</style><style font='PlantagenetCherokee' size='12'> and Boys</style></styles>")

    get :index, format: :json
    
    assert_response :success
    
    expected_title = "<styles><style font='HelveticaNeue' size='24'>Sexy girls</style><style font='HelveticaNeue' size='12'> and Boys</style></styles>"
    themes = json_response["themes"]

    assert_equal expected_title, themes.first["title"]
  end

end