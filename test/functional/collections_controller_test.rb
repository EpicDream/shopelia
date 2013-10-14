require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:elarch)
    @collection = collections(:got)
    sign_in @user
  end

  test "it should show collections" do
    get :index

    assert_response :success
  end

  test "it should show collection" do
    get :show, id:@collection.uuid

    assert_response :success
  end

  test "it should associate new product to collection" do
    assert_difference "CollectionProductVersion.count" do
      xhr :post, :add, url:"http://www.amazon.fr/gp/product/2081258498/", id:@collection.uuid

      assert_response :success
      assert_template "add"
    end
  end
end