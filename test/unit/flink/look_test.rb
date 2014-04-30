require 'test_helper'

class LookTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
    @look = looks(:agadir)
  end

  test "it should create look" do
    look = Look.new(
      name:"Article",
      flinker_id:@flinker.id,
      published_at:Time.now,
      url:"http://www.leblogdebetty.com/article")
    assert look.save, look.errors.full_messages.join(",")
    assert !look.is_published?
    assert_not_nil look.uuid
  end

  test "it should update looks count" do
    @look.is_published = true
    @look.save

    assert_equal 2, @flinker.reload.looks_count
  end

  test "it should set liked_by" do
    assert !@look.liked_by?(@flinker)
    FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    assert @look.liked_by?(@flinker)
  end
  
  test "set is_published_changed_at timestamp when a look is_published status change" do
    @look.is_published = false
    @look.save

    assert @look.flink_published_at.between?(Time.now - 10.seconds, Time.now)
  end
  
  test "get looks of followings more looks liked by followings non publishers" do
    flinker = flinkers(:fanny)
    FlinkerFollow.create!(flinker_id:flinker.id, follow_id:flinkers(:betty).id)
    FlinkerFollow.create!(flinker_id:flinker.id, follow_id:flinkers(:fanny).id)
    FlinkerLike.create!(flinker_id:flinkers(:fanny).id, resource_type:"look", resource_id:looks(:quimper).id)
    
    looks = Look.of_flinker_followings(flinker)
    
    assert_equal 3, looks.count
    assert_equal ["Agadir", "Quimper", "Thaiti"].to_set, looks.map(&:name).to_set
  end
  
end