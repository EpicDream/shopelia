# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductVersionSerializerTest < ActiveSupport::TestCase
  
  setup do
    @product = product_versions(:usbkey)
    @product.option1 = { "text" => "Rouge" }
    @product.option2 = { "text" => "34" }
    @product.option3 = nil
    @product.option4 = nil
    @product.images = ["http://ecx.images-amazon.com/images/I/41EawbtzVUL._SX450_.jpg"]
    @product.save
    @product.reload
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
    assert_equal @product.rating, hash[:product_version][:rating]
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
    assert_equal 1, hash[:product_version][:images].count
    assert_equal "http://ecx.images-amazon.com/images/I/41EawbtzVUL._SX450_.jpg", hash[:product_version][:images][0][:url]
    assert_equal "450x383", hash[:product_version][:images][0][:size]
  end

  test "it should serialize cashfront value" do
    product_serializer = ProductVersionSerializer.new(product_versions(:dvd), scope:{developer:@developer})
    hash = product_serializer.as_json
      
    assert_equal 0.30, hash[:product_version][:cashfront_value]
  end

  test "it should serialize without description and images in short mode" do
    product_serializer = ProductVersionSerializer.new(product_versions(:dvd), scope:{short:true})
    hash = product_serializer.as_json
      
    assert hash[:product_version][:description].nil?
    assert hash[:product_version][:images].nil?
  end
end