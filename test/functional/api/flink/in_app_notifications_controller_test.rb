require 'test_helper'

class Api::Flink::InAppNotificationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @flinker = flinkers(:fanny)
    sign_in @flinker
    prepare
  end
  
  teardown do
    Image.destroy_all
  end

  test "availables notifications" do
    get :index, format: :json
    
    assert_response :success
    
    notifications = json_response["notifications"]
    
    assert_equal 1, notifications.count
  end
  
  test "availables notifications for given build" do
    notif = in_app_notifications(:vacances)
    notif.update_attributes(min_build: 2, max_build: 5)
    device = @flinker.device
    device.update_attributes(build: 1)

    get :index, format: :json
    
    assert_response :success
    
    notifications = json_response["notifications"]
    
    assert_equal 0, notifications.count
  end
  
  test "availables notifications for given lang_iso" do
    notif = in_app_notifications(:vacances)
    notif.update_attributes(lang: :en)

    get :index, format: :json
    
    assert_response :success
    
    notifications = json_response["notifications"]
    
    assert_equal 0, notifications.count
  end

  test "availables notifications production only" do
    notif = in_app_notifications(:vacances)
    notif.update_attributes(production: false)

    get :index, format: :json
    
    assert_response :success
    
    notifications = json_response["notifications"]
    
    assert_equal 0, notifications.count
  end
  
  
  private
  
  def prepare
    url = "http://farm8.staticflickr.com/7344/11033879755_6dcd82ed1e_o.jpg"
    image = Image.create!(url:url)
    notif = in_app_notifications(:vacances)
    notif.image_id = image.id
    notif.save!
  end 

end