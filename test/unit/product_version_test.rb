# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductVersionTest < ActiveSupport::TestCase
  
  setup do
    @product = products(:usbkey)
  end  

  test "it should create version" do
    version = ProductVersion.new(product_id:@product.id)
    assert version.save, version.errors.full_messages.join(",")
  end
  
  test "it should parse float" do
    str = [ "2.79€", "2,79 EUR", "bla bla 2.79" ]
    str.each do |s|
      assert_equal 2.79, ProductVersion.parse_float(s)
    end
  end

  test "it should parse free shipping" do
    str = [ "LIVRAISON GRATUITE", "free shipping" ]
    str.each do |s|
      assert_equal 0, ProductVersion.parse_float(s)
    end
  end

  test "it should fail bad prices" do
    str = [ ".", "invalid" ]
    str.each do |s|
      assert_equal nil, ProductVersion.parse_float(s)
    end
  end
  
  test "it should create version with prices" do
    version = ProductVersion.new(
      product_id:@product.id,
      price:"2.79",
      price_shipping:"1",
      price_strikeout:"10.0")
    assert version.save, version.errors.full_messages.join(",")
    assert_equal 2.79, version.price
    assert_equal 1.0, version.price_shipping
    assert_equal 10.0, version.price_strikeout
  end
  
  test "it should set available info" do
    version = ProductVersion.create(
      product_id:@product.id,
      availability:"out of stock")
    assert !version.available
    version = ProductVersion.create(
      product_id:@product.id,
      availability:"stock")
    assert version.available
  end
  
end
