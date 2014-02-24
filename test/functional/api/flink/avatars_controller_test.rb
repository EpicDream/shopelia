require 'test_helper'

class Api::Flink::AvatarsControllerTest < ActionController::TestCase     
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
  end
  
  test "upload avatar" do
    @flinker.avatar = nil
    @flinker.save!
    assert_match(/missing/, @flinker.avatar.url)
    
    post :create, format: :json, avatar:File.new("#{Rails.root}/app/assets/images/admin/girl_head.jpg")
    
    assert_response :success
    assert_not_match(/missing/, @flinker.reload.avatar.url)
    assert_equal "/images/flinker/#{@flinker.id}/original/avatar.jpg", @flinker.avatar.url
  end

end
