require 'test_helper'

class Developers::TrackingControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @developer = developers(:shopelia)
    sign_in @developer
  end

  test "should show all products tracked" do
    get :index
    assert_response :success
  end
  
  test "should add urls" do
    assert_difference "DeveloperProductsWorker.jobs.count" do
      post :create, urls:"http://www.amazon.fr/gp/product/B00F8BW3I8"
      assert_redirected_to developers_tracking_index_path
    end

    assert_difference ["Product.count", "Event.count"] do
      DeveloperProductsWorker.drain
    end

    assert_equal 1, @developer.reload.products.count
  end

  test "should remove product" do
    @developer.products << products(:dvd)

    assert_difference "@developer.products.count", -1 do
      xhr :delete, :destroy, id: products(:dvd).id
    end
  end
end