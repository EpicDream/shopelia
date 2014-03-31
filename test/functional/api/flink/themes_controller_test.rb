require 'test_helper'

class Api::Flink::ThemesControllerTest < ActionController::TestCase     
  include Devise::TestHelpers
  
  setup do
    @fanny = flinkers(:fanny)
    sign_in @fanny
    Theme.published(true).each { |theme| theme.send(:assign_default_cover) }
  end

  test "get themes published with minimal informations" do
    get :index, format: :json
    
    assert_response :success
    
    themes = json_response["themes"]
    
    assert_equal 2, themes.count
    assert_equal ["La mode c'est fun", "Sexy girls"].to_set, themes.map{ |t| t["title"] }.to_set
  end
  
  test "get theme detail" do
    theme = Theme.first
    
    get :show, format: :json, id:theme.id
    
    assert_response :success
    
    puts json_response.inspect
    theme = json_response["theme"]
  end

end