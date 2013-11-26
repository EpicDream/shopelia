require 'test_helper'

class Api::Customers::Merkav::MerkavTransactionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    ENV["API_KEY"] = developers(:merkav).api_key
  end

  test "it should create a new merkav transaction" do
    assert_difference ["MerkavTransaction.count","MerkavWorker.jobs.count"] do
      post :create, merkav_transaction:{amount:100,vad_id:1}, format: :json
      assert_response :success
      @id = json_response["id"]
    end

    transaction = MerkavTransaction.find_by_id(@id)
    assert_not_nil transaction
    assert_equal 100, transaction.amount
    assert_equal 1, transaction.vad_id
  end

  test "it should show a merkav transaction" do
    get :show, id:merkav_transactions(:one), format: :json
    assert_response :success
    assert_equal merkav_transactions(:one).id, json_response["id"]
  end

  test "it should get all transactions" do
    get :index, format: :json
    assert_response :success
    assert_equal 1, json_response.count
  end

  test "it should authorize only merkav developer api key" do
    ENV["API_KEY"] = developers(:prixing).api_key
     get :index, format: :json
    assert_response :unauthorized
  end
end