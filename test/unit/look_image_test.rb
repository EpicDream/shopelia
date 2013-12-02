require 'test_helper'

class LookImageTest < ActiveSupport::TestCase
  
  setup do
    @look = looks(:agadir)
    @url = "http://farm8.staticflickr.com/7344/11033879755_6dcd82ed1e_o.jpg"
  end
  
  teardown do
    LookImage.destroy_all #to clear paper clip files
  end

  test "it should create look image" do
    assert_difference "LookImage.count" do
      @look.look_images << LookImage.create(url:@url)
    end
    assert_equal 1, @look.reload.look_images.count
  end
  
  test "a look image must belongs to a look" do
    assert_difference("LookImage.count", 0) do
      look_image = LookImage.create(url:@url)
      assert !look_image.valid?
    end
  end
  
  test "it shouldn't allow duplicate url for a look" do
    @look.look_images << LookImage.create(url:@url)
    @look.look_images << LookImage.create(url:@url)
    assert_equal 1, @look.reload.look_images.count
  end
end