require 'test_helper'

class Api::Vulcain::MerchantsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @merchant = merchants(:amazon)
  end

  test "it should update merchant data" do
    post :update, id:@merchant.vendor.underscore, pass:true, output:"bla", format: :json
    
    assert_response :success
    assert_equal true, @merchant.reload.vulcain_test_pass
    assert_equal "bla", @merchant.vulcain_test_output
  end  
end

