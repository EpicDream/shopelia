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
    image_url = "http://www.flink.io/images/e5c/original/e5ce9070e3df4bd078a26bf29f1bbde4.jpg"

    assert_equal 1, notifications.count
    assert_equal image_url, notifications.first["image_url"]
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
  
  test "availables notifications published and prepublished if user is dev" do
    @flinker.device.update_attributes(is_dev:true)

    get :index, format: :json
    
    assert_response :success
    
    notifications = json_response["notifications"]
    
    assert_equal 2, notifications.count
  end
  
  private
  
  def prepare
    url = "http://farm8.staticflickr.com/7344/11033879755_6dcd82ed1e_o.jpg"
    image = Image.create!(url:url)
    InAppNotification.update_all(image_id: image.id)
  end 

end