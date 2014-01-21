# -*- encoding : utf-8 -*-
require 'test_helper'

class CommentSerializerTest < ActiveSupport::TestCase

  setup do
    @flinker = flinkers(:lilou)
    build_look

    Comment.any_instance.stubs(:can_be_posted_on_blog?).returns(true)
    commenter = Poster::Comment.new
    commenter.expects(:deliver)
    Poster::Comment.expects(:new).with(comment).returns(commenter)

    @comment = Comment.create(body: "trop belle", flinker_id:@flinker.id, look_id:@look.id)
  end

  test "it should correctly serialize comment" do

    comment_serializer = CommentSerializer.new(@comment)
    hash = comment_serializer.as_json

    assert_equal @comment.id, hash[:comment][:id]
    assert_equal @comment.body, hash[:comment][:body]
    assert_equal @comment.created_at.to_i, hash[:comment][:created_at]
    assert hash[:comment][:flinker].present?

  end

  private

  def comment
    {:comment=>"#{@flinker.username} <br/> trop belle <br/> send via  <a href='http://flink.io'>flink</a>}", :author=>"#{@flinker.username}", :email=>"hello@flink.io", :post_url=>"#{@look.url}"}
  end

  def build_look
    @look = Look.create!(
        name:"Article",
        flinker_id:@flinker.id,
        published_at:1.day.ago,
        is_published:true,
        url:"http://www.leblogdebetty.com/article")
  end
end