# -*- encoding : utf-8 -*-
require 'test_helper'

class ProductVersionTest < ActiveSupport::TestCase
  
  setup do
    @product = products(:usbkey)
    @version = ProductVersion.new(product_id:@product.id)
  end  

  test "it should create version" do
    assert @version.save, @version.errors.full_messages.join(",")
  end
  
  test "it should parse float" do
    str = [ "2.79€", "2,79 EUR", "bla bla 2.79", "2€79", 
            "2��79", "2,79 €7,30 €", "2€79 6€30", "2,79 ��7,30 ��", 
            "2��79 6��30" ]
    str.each do |s|
      @version.price = s
      @version.price_strikeout = s
      @version.price_shipping = s
      @version.save
      assert_equal 2.79, @version.price, s
      assert_equal 2.79, @version.price_strikeout, s
      assert_equal 2.79, @version.price_shipping, s
    end
    str = [ "2", "2€", "Bla bla 2 €" ]
    str.each do |s|
      @version.price = s
      @version.price_strikeout = s
      @version.price_shipping = s
      @version.save
      assert_equal 2, @version.price, s
      assert_equal 2, @version.price_strikeout, s
      assert_equal 2, @version.price_shipping, s
    end
  end

  test "it should parse free shipping" do
    str = [ "LIVRAISON GRATUITE", "free shipping", "Livraison offerte" ]
    str.each do |s|
      @version.price_shipping = s
      @version.save
      assert_equal 0, @version.price_shipping, s
    end
  end

  test "it should fail bad prices" do
    str = [ ".", "invalid" ]
    str.each do |s|
      @version.price = s
      @version.save
      assert_equal nil, @version.price, s
    end
  end
  
  test "it should generate incident if shipping is not correctly parsed" do
    assert_difference "Incident.count", 1 do
      @version.price_shipping = "Invalid string"
      @version.save
    end
  end

  test "it should generate incident if shipping price is too high" do
    assert_difference "Incident.count", 1 do
      @version.price_shipping = "1000"
      @version.save
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
