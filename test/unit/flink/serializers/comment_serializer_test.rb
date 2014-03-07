require 'test_helper'

class CommentSerializerTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:lilou)
    @look = looks(:agadir)
  end

  test "serialize comment" do
    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(true)

    @comment = Comment.create(body: "trop belle", flinker_id:@flinker.id, look_id:@look.id)

    comment_serializer = CommentSerializer.new(@comment)
    hash = comment_serializer.as_json

    assert_equal @comment.id, hash[:comment][:id]
    assert_equal @comment.body, hash[:comment][:body]
    assert_equal @comment.created_at.to_i, hash[:comment][:created_at]
    assert_equal @comment.posted, hash[:comment][:posted]
    assert hash[:comment][:flinker].present?
  end

  private

  def comment
    {:comment=>"#{@flinker.username} <br/> trop belle <br/> send via  <a href='http://flink.io'>flink</a>", :author=>"#{@flinker.username}", :email=>"flinkhq@gmail.com", :post_url=>"#{@look.url}"}
  end

end