# -*- encoding : utf-8 -*-
require 'test_helper'

class MerchantTest < ActiveSupport::TestCase

  test "it should create merchant" do
    populate_merchant
    assert @merchant.save, @merchant.errors.full_messages.join(",")
    assert @merchant.allow_quantities?
  end

  test "it shouldn't destroy merchant if it has any order" do
    assert !merchants(:rueducommerce).destroy
  end
  
  test "it should destroy merchant if it hasn't any order" do
    populate_merchant
    @merchant.save
    assert @merchant.destroy
  end
  
  test "merchant should accept order" do
    populate_merchant
    @merchant.save
    assert @merchant.accepting_orders?
  end
  
  test "it should find merchant from a supported product url" do
    assert_equal merchants(:rueducommerce).id, Merchant.from_url("http://www.rueducommerce.fr/bla").id
  end
  
  test "it should create merchant from a new merchant product url" do
    assert_difference('Merchant.count', 1) do
      merchant =  Merchant.from_url("http://www.amazon.co.uk/gp/product/B007OZO03M/ref=s9_pop_gw_g349_ir03?pf_rd_m=A3P5ROKL5A1OLE&pf_rd_s=center-2&pf_rd_r=0KBJFT6QS74TAYTT1SGZ&pf_rd_t=101&pf_rd_p=358550247&pf_rd_i=468294")
      assert merchant.present?
      assert_equal "amazon.co.uk", merchant.name
      assert_equal "amazon.co.uk", merchant.domain
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
      :accepting_orders => true,
      :tc_url => 'http://www.amazon.uk/gp/help/customer/display.html/ref=hp_rel_topic?ie=UTF8&nodeId=548524#conditions_vente')
  end

end
