require 'test_helper'

class Api::Viking::MappingsControllerTest < ActionController::TestCase
  fixtures :mappings, :merchants

  setup do
    @merchant = merchants(:fnac)
    @mapping = mappings(:fnac_map)
  end

  test "it should find all mappings" do
    get :index
    assert_response :success
    assert_kind_of Array, json_response
  end

  test "it should find mapping by url" do
    get :index, url: "http://www.fnac.com/bla"
    assert_response :success
    assert_equal @mapping.id, json_response["id"]
  end

  test "it should find mapping by merchant_id" do
    get :index, merchant_id: @merchant.id
    assert_response :success
    assert_equal @mapping.id, json_response["id"]
  end

  test "it should find mapping by id" do
    get :show, id: @mapping.id
    assert_response :success
    assert_equal @mapping.id, json_response["id"]
    assert_equal @mapping.domain, json_response["domain"]
  end
  
  test "it should create mapping" do
    assert_difference "Mapping.count" do
      post :create, data: {"domain" => "amazon.fr", "mapping" => '{"default":{"name":{"paths":["#name"]}}}'}
      assert_response :success
      assert json_response["id"].present?
      assert_equal "amazon.fr", json_response["domain"]
      assert_kind_of String, json_response["mapping"]
    end
  end
  
  test "it should update mapping" do
    assert_equal '{"default":{"price":{"paths":["#path.to.price"]}}}', @mapping.mapping
    post :update, id:@mapping.id, data:{"mapping" => '{"default":{"price":{"paths":["#updatedPath.to.price"]}}}'}
    assert_response :success
    assert_equal '{"default":{"price":{"paths":["#updatedPath.to.price"]}}}', @mapping.reload.mapping
  end
end
