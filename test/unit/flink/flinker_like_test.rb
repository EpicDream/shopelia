require 'test_helper'

class FlinkerLikeTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
    @look = looks(:agadir)
    @product = products(:nounours)
  end

  test "it should create flinker like for product" do
    like = FlinkerLike.new(flinker_id:@flinker.id, resource_type:FlinkerLike::PRODUCT, resource_id:@product.id)
    assert like.save
  end

  test "it should create flinker like for look" do
    like = FlinkerLike.new(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    assert like.save
  end

  test "it shouldn't be able to create duplicate likes" do
    FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    like = FlinkerLike.new(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    assert !like.save
  end

  test "two flinkers can like the same resource" do
    FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    like = FlinkerLike.new(flinker_id:flinkers(:elarch).id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    assert like.save
  end
  
  test "top like flinkers ordered" do
    flinkers = FlinkerLike.top_likers.map(&:flinker)

    assert_equal 3, flinkers.count
    assert_equal flinkers(:boop), flinkers.first 
    assert_equal flinkers(:betty), flinkers.last 
  end
  
  test "create like activity for look like" do
    FlinkerLike.destroy_all
    @flinker = flinkers(:boop)
    
    LikeActivity.expects(:create!)
    FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
  end
  
end
