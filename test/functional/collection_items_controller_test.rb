require 'test_helper'

class CollectionItemsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:elarch)
    @item = collection_items(:one)
    sign_in @user
  end

  test "it should show item" do
    get :show, id:@item.id
    assert_response :success
  end
end