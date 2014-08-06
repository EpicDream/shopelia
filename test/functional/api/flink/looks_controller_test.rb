require 'test_helper'

class Api::Flink::LooksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    Look.destroy_all
    @flinker = flinkers(:betty)
    sign_in @flinker
    
    build_looks
  end

  test "it should get first 10 looks" do
    get :index, format: :json
    assert_response :success
    
    assert_equal 10, json_response["looks"].count
  end

  test "it should get first 20 looks" do
    get :index, format: :json, per_page:20
    assert_response :success
    
    assert_equal 20, json_response["looks"].count
  end

  test "it should get looks after a date" do
    get :index, format: :json, published_after:(5.month.ago - 1.day).to_i
    assert_response :success
    
    assert_equal 7, json_response["looks"].count
  end

  test "it should get looks before a date" do
    get :index, format: :json, published_before:(15.month.ago - 1.day).to_i
    assert_response :success
    
    assert_equal 5, json_response["looks"].count
  end

  test "it should reply with 401 when getting liked looks and not logged in" do
    sign_out @flinker
    get :index, format: :json, liked:1
    
    assert_response 401
  end

  test "it should get liked looks of current flinker" do
    FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:Look.last.id)

    get :index, format: :json, liked:1
    
    assert_response :success
    assert_equal 1, json_response["looks"].count
    assert_equal Look.last.uuid, json_response["looks"].first["uuid"]
  end 
  
  test "it should get liked looks of flinker" do
    flinker = flinkers(:fanny)
    FlinkerLike.create!(flinker_id:flinker.id, resource_type:FlinkerLike::LOOK, resource_id:Look.first.id)

    get :index, format: :json, liked:1, flinker_id:flinker.id
    
    assert_response :success
    assert_equal 1, json_response["looks"].count
    assert_equal Look.first.uuid, json_response["looks"].first["uuid"]
  end 

  test "it should get only looks you are following (2)" do
    sign_in flinkers(:elarch)

    FlinkerFollow.create!(flinker_id:flinkers(:elarch).id, follow_id:flinkers(:betty).id)
    get :index, format: :json
    assert_equal 10, json_response["looks"].count
  end

  test "it should get only looks from flinker_ids" do
    sign_in flinkers(:elarch)
    FlinkerFollow.create!(flinker_id:flinkers(:elarch).id, follow_id:flinkers(:elarch).id)

    get :index, flinker_ids:[flinkers(:betty).id], format: :json
    assert_equal 10, json_response["looks"].count
  end
  
  test "get looks for given looks uuids" do
    looks = Look.first(2)

    get :index, format: :json, looks_ids:looks.map(&:uuid)

    assert_response :success
    assert_equal 2, json_response["looks"].count
    assert_equal looks.map(&:uuid), json_response["looks"].map { |l| l["uuid"] }
  end

  private

  def build_looks
    build_look(1.day.ago)
    build_look(10.days.ago)
    (1..20).to_a.each do |i|
      build_look(i.month.ago)
    end
  end

  def build_look published_at, staff_pick=true
    Look.create!(
      name:"Article",
      flinker_id:@flinker.id,
      published_at:published_at,
      flink_published_at:published_at + 1.minute,
      is_published:true,
      staff_pick:staff_pick,
      url:"http://www.leblogdebetty.com/article")
  end
end