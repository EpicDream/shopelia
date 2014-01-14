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

    assert_equal 1, @flinker.reload.looks_count
  end

  test "it should set liked_by" do
    assert !@look.liked_by?(@flinker)
    FlinkerLike.create!(flinker_id:@flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    assert @look.liked_by?(@flinker)
  end
end