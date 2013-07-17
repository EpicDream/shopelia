# -*- encoding : utf-8 -*-
require 'test_helper'

class MerchantTest < ActiveSupport::TestCase
  fixtures :merchants, :orders

  test "it should create merchant" do
    populate_merchant
    assert @merchant.save, @merchant.errors.full_messages.join(",")
  end

  test "it shouldn't destroy merchant if it has any order" do
    assert !merchants(:rueducommerce).destroy
  end
  
  test "it should destroy merchant if it hasn't any order" do
    populate_merchant
    assert @merchant.destroy
  end
  
  test "merchant should accept order" do
    populate_merchant
    assert @merchant.accepting_orders?
  end
  
  test "it should find merchant from a supported product url" do
    assert_equal merchants(:rueducommerce).id, Merchant.from_url("http://www.rueducommerce.fr/bla").id
  end
  
  test "it should create merchant from a new merchant product url" do
    assert_difference('Merchant.count', 1) do
      merchant =  Merchant.from_url("http://www.bla.com/product")
      assert merchant.present?
      assert_equal "bla.com", merchant.name
      assert_equal "bla.com", merchant.domain
    end
  end

  test "it shouldn't create merchant from a new merchant product url if specified so" do
    assert_difference('Merchant.count', 0) do
      merchant =  Merchant.from_url("http://www.bla.com/product", false)
      assert merchant.nil?
    end
  end
  
  test "it should match url with accents" do
    assert_equal merchants(:rueducommerce).id, Merchant.from_url("http://www.rueducommerce.fr/bla-accent-é").id
  end
  
  private
  
  def populate_merchant
    @merchant = Merchant.new(
      :name => 'Amazon UK',
      :vendor => 'AmazonUk',
      :domain => 'amazon.uk',
      :logo => 'http://www.achatsweb.fr/wp-content/uploads/2012/03/Amazon-fr.jpeg',
      :url => 'http://www.amazon.uk',
      :tc_url => 'http://www.amazon.uk/gp/help/customer/display.html/ref=hp_rel_topic?ie=UTF8&nodeId=548524#conditions_vente')
  end

end
