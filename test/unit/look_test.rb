require 'test_helper'

class LookTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:betty)
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

  test "it should set post processed_at when publishing look" do
    post = Post.create(link: "http://www.toto.fr", title:"Name", published_at:Time.now, products:{}.to_json, images:[].to_json, blog_id: blogs(:betty).id)
    look = post.generate_look

    look.update_attribute :is_published, true
    assert_not_nil post.reload.processed_at
  end
end