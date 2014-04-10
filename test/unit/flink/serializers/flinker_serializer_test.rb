require 'test_helper'

class FlinkerSerializerTest < ActiveSupport::TestCase
  
  setup do
    @flinker = flinkers(:betty)
  end
  
  test "serialize flinker" do
    serializer = FlinkerSerializer.new(@flinker)
    hash = serializer.as_json
      
    assert_equal @flinker.id, hash[:flinker][:id]
    assert_equal @flinker.name, hash[:flinker][:name]
    assert_equal @flinker.url, hash[:flinker][:url]
    assert_equal Rails.configuration.image_host + @flinker.avatar.url(:thumb), hash[:flinker][:avatar]
    assert_equal 1, hash[:flinker][:staff_pick]
    assert_equal "FR", hash[:flinker][:country]
    assert_equal 2, hash[:flinker][:liked_count]
    assert_nil hash[:flinker][:cover_large]
    assert_nil hash[:flinker][:cover_small]
    assert hash[:flinker].has_key?(:verified)
  end
  
  test "serialize non publisher without liked count" do
    flinker = flinkers(:fanny)
    hash = FlinkerSerializer.new(flinker).as_json
    
    assert !hash[:flinker].has_key?(:liked_count)
  end
  
  test "flinker with cover image" do
    look = @flinker.looks.first
    image = LookImage.new(url:"http://flink.io")
    image.look = look
    image.picture = File.new("#{Rails.root}/app/assets/images/admin/default-cover.png")
    image.save!
    
    serializer = FlinkerSerializer.new(@flinker)
    object = serializer.as_json
      
    assert_equal cover_url('pico'), object[:flinker][:cover_small]
    assert_equal cover_url('large'), object[:flinker][:cover_large]
    assert_equal cover_url('small'), object[:flinker][:cover_medium]
  end
  
  private
  
  def cover_url format
    Rails.configuration.image_host + "/images/ae4/#{format}/ae4fc89942443f7d5dda587fd1791ee7.jpg"
  end
  
end