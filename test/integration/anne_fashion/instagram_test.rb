# encoding: UTF-8
require 'test__helper'
require 'anne_fashion/instagram'

class AnneFashion::InstagramTest < ActiveSupport::TestCase
  
  setup do
    @client = AnneFashion::Instagram.new
  end
  
  test "authentication" do
    assert @client.me.username == 'huitrebzh'
  end
  
end
