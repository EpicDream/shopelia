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
    get :index, format: :json, published_after:5.month.ago.to_i
    assert_response :success
    
    assert_equal 7, json_response["looks"].count
  end

  test "it should get looks before a date" do
    get :index, format: :json, published_before:15.month.ago.to_i
    assert_response :success
    
    assert_equal 5, json_response["looks"].count
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
      is_published:true,
      url:"http://www.leblogdebetty.com/article")
  end
end