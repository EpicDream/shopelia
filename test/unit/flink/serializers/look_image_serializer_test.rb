# -*- encoding : utf-8 -*-
require 'test_helper'

class LookImageSerializerTest < ActiveSupport::TestCase
  
  setup do
    look = looks(:agadir)
    url = "http://farm8.staticflickr.com/7344/11033879755_6dcd82ed1e_o.jpg"
    look.look_images << LookImage.create(url:url)
    @image = LookImage.first
  end

  teardown do
    LookImage.destroy_all #to clear paper clip files
  end  
  
  test "it should correctly serialize image" do
    image_serializer = LookImageSerializer.new(@image)
    hash = image_serializer.as_json
      
    assert_equal @image.id, hash[:look_image][:id]
    assert_equal Rails.configuration.image_host + @image.picture.url(:pico), hash[:look_image][:small][:url]
    assert_equal "33x50", hash[:look_image][:small][:size]
    assert_equal Rails.configuration.image_host + @image.picture.url(:large), hash[:look_image][:large][:url]
    assert_equal "650x975", hash[:look_image][:large][:size]
  end
end