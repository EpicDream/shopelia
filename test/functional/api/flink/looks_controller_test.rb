require 'test_helper'

class Api::Flink::LooksControllerTest < ActionController::TestCase

  setup do
    post = Post.create!(
      link: "http://www.toto.fr", 
      title:"test", 
      published_at:Time.now, 
      blog_id: blogs(:betty).id,
      products:{"Amazon"=>"http://www.amazon.fr/dp/B00BIXXTCY"}.to_json,
      images:["http://farm4.staticflickr.com/3681/10980880355_0a0151fbd1_o.jpg","http://mytrendymarket.com/wp-content/uploads/2013/11/pull-maiami-1.png"].to_json)
    @look = post.look
    @look.update_attribute :is_published, true
  end
  
  teardown do
    LookImage.destroy_all #to clear paper clip files
  end 

  test "it should get all looks" do
    get :index, format: :json
    assert_response :success
    
    assert json_response.kind_of?(Array), "Should get an array of looks"
    assert_equal 1, json_response.count
  end
end