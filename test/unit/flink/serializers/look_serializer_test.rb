require 'test_helper'

class LookSerializerTest < ActiveSupport::TestCase
  
  setup do
    LookProduct.any_instance.stubs(:generate_event)
    
    post = Post.create!(
      link: "http://www.toto.fr", 
      title:"test", 
      published_at:Time.now, 
      blog_id: blogs(:betty).id,
      content: "Stairway to heaven",
      products:{"Amazon"=>"http://www.amazon.fr/dp/B00BIXXTCY"}.to_json,
      images:["http://farm4.staticflickr.com/3681/10980880355_0a0151fbd1_o.jpg","http://mytrendymarket.com/wp-content/uploads/2013/11/pull-maiami-1.png"].to_json)
    @look = post.look
    @look_product = LookProduct.create(look_id:@look.id,brand:"Zara",code:"jean")
  end

  teardown do
    LookImage.destroy_all #to clear paper clip files
  end  
  
  test "serialize look" do
    @look.update_attributes(flink_published_at:Time.now + 1.day, staff_pick:true)
    look_serializer = LookSerializer.new(@look)
    hash = look_serializer.as_json

    assert_equal @look.uuid, hash[:look][:uuid]
    assert_equal @look.name, hash[:look][:name]
    assert_equal @look.url, hash[:look][:url]
    assert_equal @look.published_at.to_i, hash[:look][:published_at]
    assert_equal @look.updated_at.to_i, hash[:look][:updated_at]
    assert_equal @look.flink_published_at.to_i, hash[:look][:flink_published_at]
    
    assert hash[:look][:flinker].present?
    assert_equal 1, hash[:look][:products].count
    assert_equal "Jean", hash[:look][:products].first[:code]
    assert_equal "Zara", hash[:look][:products].first[:brand]
    assert_equal @look_product.uuid, hash[:look][:products].first[:uuid]
    
    assert_equal 2, hash[:look][:images].count
    assert hash[:look][:liked].nil?
    assert hash[:look][:staff_pick]
    
    assert_equal "Stairway to heaven", hash[:look][:description]
    assert_equal 0, hash[:look][:highlighted_hashtags].count
  end

  test "it should set liked by" do
    flinker = flinkers(:elarch)
      
    look_serializer = LookSerializer.new(@look, scope:{flinker:flinker})
    assert_equal 0, look_serializer.as_json[:look][:liked]

    FlinkerLike.create!(flinker_id:flinker.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    look_serializer = LookSerializer.new(@look, scope:{flinker:flinker})
    assert_equal 1, look_serializer.as_json[:look][:liked]
  end

  test "it should translate codes" do
    I18n.locale = :fr
    flinker = flinkers(:elarch)
    @look.look_products.destroy_all
    product = LookProduct.create!(look_id:@look.id, code:"dress", brand:"test")
    
    look_serializer = LookSerializer.new(@look.reload, scope:{flinker:flinker})
    hash = look_serializer.as_json

    assert_equal "Robe", hash[:look][:products][0][:code]
    assert_equal "test", hash[:look][:products][0][:brand]
  end
  
  test "associated highlighted hashtags" do
    hashtags = ["Top", "Canon"].map { |name| Hashtag.find_or_create_by_name(name)  }
    @look.hashtags << hashtags
    HighlightedLook.create(look_id:@look.id, hashtag_id:hashtags.first.id)
    
    look_serializer = LookSerializer.new(@look)
    hash = look_serializer.as_json

    assert_equal 1, hash[:look][:highlighted_hashtags].count
    assert_equal ["Top"], hash[:look][:highlighted_hashtags]
  end
  
  test "associated comments and likes count" do
    Comment.create(body:"Hey", look_id:@look.id, flinker_id:Flinker.last.id)
    FlinkerLike.create(flinker_id:Flinker.last.id, resource_type:FlinkerLike::LOOK, resource_id:@look.id)
    
    look_serializer = LookSerializer.new(@look)
    hash = look_serializer.as_json

    assert_equal 1, hash[:look][:comments_count]
    assert_equal 1, hash[:look][:likes_count]
  end
  
  test "include look product uuid" do
    @look.look_products.destroy_all
    product = LookProduct.create!(look_id:@look.id, code:"dress", brand:"test")
    
    look_serializer = LookSerializer.new(@look.reload, scope:{flinker:Flinker.last})
    hash = look_serializer.as_json

    assert_equal product.uuid, hash[:look][:products][0][:uuid]
  end
end
