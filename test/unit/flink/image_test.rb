require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  
  setup do
    url = "http://farm8.staticflickr.com/7344/11033879755_6dcd82ed1e_o.jpg"
    @image = Image.create!(url:url)
  end
  
  teardown do
    Image.destroy_all #to clear paper clip files
  end
  
  test "create image from its www url" do
    path_match = Regexp.new("/images/e5c/small/e5ce9070e3df4bd078a26bf29f1bbde4.jpg")
    assert_match path_match, @image.picture.url(:small)
  end
  
  test "build images sizes as json field" do
    image = @image.reload
    sizes = {pico:"33x50",small:"320x480",large:"650x975"}
    assert_equal sizes.to_json, @image.picture_sizes
  end

  test "add model error if picture can't be created from url" do
    image = Image.create(url:"http://")
    
    assert_equal 1, image.errors.count
    assert !image.valid?
  end  
end