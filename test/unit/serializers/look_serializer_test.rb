# -*- encoding : utf-8 -*-
require 'test_helper'

class LookSerializerTest < ActiveSupport::TestCase
  
  setup do
    post = Post.create!(
      link: "http://www.toto.fr", 
      title:"test", 
      published_at:Time.now, 
      blog_id: blogs(:betty).id,
      products:{"Amazon"=>"http://www.amazon.fr/dp/B00BIXXTCY"}.to_json,
      images:["http://farm4.staticflickr.com/3681/10980880355_0a0151fbd1_o.jpg","http://mytrendymarket.com/wp-content/uploads/2013/11/pull-maiami-1.png"].to_json)
    @look = post.look
  end

  teardown do
    LookImage.destroy_all #to clear paper clip files
  end  
  
  test "it should correctly serialize look" do
    look_serializer = LookSerializer.new(@look)
    hash = look_serializer.as_json
      
    assert_equal @look.uuid, hash[:look][:uuid]
    assert_equal @look.name, hash[:look][:name]
    assert_equal @look.url, hash[:look][:url]
    assert_equal @look.published_at.to_i, hash[:look][:published_at]
    assert hash[:look][:flinker].present?
    assert_equal 0, hash[:look][:products].count
    assert_equal 2, hash[:look][:images].count
  end
end