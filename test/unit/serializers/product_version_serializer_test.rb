# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductVersionSerializerTest < ActiveSupport::TestCase
  
  setup do
    @product = product_versions(:usbkey)
    @product.option1 = { "text" => "Rouge" }
    @product.option2 = { "text" => "34" }
    @product.option3 = nil
    @product.option4 = nil
    @product.save
    @developer = developers(:prixing)
  end
  
  test "it should correctly serialize product version" do
    product_serializer = ProductVersionSerializer.new(@product)
    hash = product_serializer.as_json
      
    assert_equal @product.id, hash[:product_version][:id]
    assert_equal @product.name, hash[:product_version][:name]
    assert_equal @product.image_url, hash[:product_version][:image_url]
    assert_equal @product.description, hash[:product_version][:description]
    assert_equal "Rouge", hash[:product_version][:option1]["text"]
    assert_equal "34", hash[:product_version][:option2]["text"]
    assert hash[:product_version][:option2_md5].present?
    assert hash[:product_version][:option2_md5].present?
    assert hash[:product_version][:option3].nil?
    assert hash[:product_version][:option4].nil?
    assert hash[:product_version][:option3_md5].nil?
    assert hash[:product_version][:option4_md5].nil?    
    assert_equal @product.price_shipping, hash[:product_version][:price_shipping]
    assert_equal @product.price_strikeout, hash[:product_version][:price_strikeout]
    assert_equal @product.shipping_info, hash[:product_version][:shipping_info]
    assert_equal @product.availability_info, hash[:product_version][:availability_info]
    assert_equal 0, hash[:product_version][:cashfront_value]
    assert_equal 1, hash[:product_version][:available]    
  end

  test "it should serialize cashfront value" do
    product_serializer = ProductVersionSerializer.new(product_versions(:dvd), scope:{developer:@developer})
    hash = product_serializer.as_json
      
    assert_equal 0.30, hash[:product_version][:cashfront_value]
  end

end

