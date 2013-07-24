require 'test_helper'

class AddressesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:elarch)
    @address = addresses(:elarch_neuilly)
    sign_in @user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_match /Neuilly/, response.body
  end

  test "should show address" do
    get :show, id: @address.id
    assert_response :success
  end

  test "should create address via ajax" do
    assert_difference('Address.count') do
      xhr :post, :create, :address => {
        :address1 => "17bis rue Jean Grazcyk",
        :zip => "18500",
        :city => "Vignoux sur Barangeon",
        :phone => "0248515290",
        :country_id => countries(:france).id
      }
    end
    
    assert_response :success
  end


  test "should destroy address" do
    assert_difference('Address.count', -1) do
      delete :destroy, id: @address.id
    end

    assert_redirected_to addresses_path
  end
  
  test "should destroy address via ajax" do
    assert_difference('Address.count', -1) do
      xhr :delete, :destroy, id: @address.id
    end
    
    assert_response :success
  end
end
