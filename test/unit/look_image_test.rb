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
  end
end