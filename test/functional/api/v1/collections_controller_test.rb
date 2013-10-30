require 'test_helper'

class Api::V1::CollectionsControllerTest < ActionController::TestCase

  setup do
    @collection = collections(:got)
  end

  test "it should get all collections by tag" do
    get :index, tags:["__Home"], format: :json
    assert_response :success
    
    assert json_response.kind_of?(Array), "Should get an array of collections"
    assert_equal 1, json_response.count
    assert_equal "Game of Thrones", json_response.first["name"]
  end

  test "it should get empty array if no collections found" do
    get :index, tags:["__Home","Deco"], format: :json
    assert_response :success
    
    assert_equal 0, json_response.count
  end

  test "it should get all items from collection" do
    get :show, id:@collection.uuid, format: :json
    assert_response :success

    assert_equal 2, json_response.count
  end
end