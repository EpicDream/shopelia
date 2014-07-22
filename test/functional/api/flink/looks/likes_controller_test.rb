require 'test_helper'

class Api::Flink::Looks::LikesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @look = looks(:agadir)
    @flinker = flinkers(:betty)
    sign_in @flinker
  end

  test "create like" do
    assert_difference "FlinkerLike.count" do
      post :create, look_id:@look.uuid, format: :json
      assert_response :success
    end
  end

  test "toggle like to on false" do
    like = FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    
    assert_difference "FlinkerLike.count", -1 do
      post :destroy, look_id:@look.uuid, format: :json
      assert_response :success
    end  
    
    assert !like.reload.on  
  end
  
  test "toggle like to on true when like exists" do
    like = FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id, on: false)
    
    assert_no_difference "FlinkerLike.unscoped { FlinkerLike.count} " do
      post :create, look_id:@look.uuid, format: :json
      assert_response :success
    end
  end
  
end