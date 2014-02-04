require 'test_helper'

class Api::Flink::LooksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    Look.destroy_all
    @flinker = flinkers(:betty)
    build_looks
  end

  test "it should get first 10 looks" do
    get :index, format: :json
    assert_response :success
    
    assert_equal 10, json_response["looks"].count
    assert_equal 10, json_response["per_page"]
  end

  test "it should get first 20 looks" do
    get :index, format: :json, per_page:20
    assert_response :success
    
    assert_equal 20, json_response["looks"].count
    assert_equal 20, json_response["per_page"]
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
    get :index, format: :json, liked:1
    assert_response 401
  end

  test "it should get liked looks" do
    sign_in @flinker

    FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:Look.last.id)

    get :index, format: :json, liked:1
    assert_response :success
    assert_equal 1, json_response["looks"].count
  end 

  test "it should get only looks you are following (1)" do
    sign_in flinkers(:elarch)

    FlinkerFollow.create!(flinker_id:flinkers(:elarch).id, follow_id:flinkers(:elarch).id)
    get :index, format: :json
    assert_equal 0, json_response["looks"].count
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
  
  test "get looks published, updated after <timestamp> (and published before <timestamp>)" do
    sign_in flinkers(:elarch)
    FlinkerFollow.create!(flinker_id:flinkers(:elarch).id, follow_id:flinkers(:betty).id)
    
    look = Look.last
    look.updated_at = Time.now + 1.hour
    look.save

    get :index, format: :json, updated_after:(Time.now + 2.minutes).to_i
    
    assert_equal 1, json_response["looks"].count
  end

  private

  def build_looks
    build_look(1.day.ago)
    build_look(10.days.ago)
    (1..20).to_a.each do |i|
      build_look(i.month.ago)
    end
  end

  def build_look published_at
    Look.create!(
      name:"Article",
      flinker_id:@flinker.id,
      published_at:published_at,
      is_published_updated_at:Time.now,
      is_published:true,
      url:"http://www.leblogdebetty.com/article")
  end
end