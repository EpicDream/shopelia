require 'test_helper'

class MerchantTest < ActiveSupport::TestCase
  fixtures :merchants

  test "it should create merchant" do
    merchant = Merchant.new(
      :name => 'Amazon UK',
      :vendor => 'AmazonUk',
      :logo => 'http://www.achatsweb.fr/wp-content/uploads/2012/03/Amazon-fr.jpeg',
      :url => 'http://www.amazon.uk',
      :tc_url => 'http://www.amazon.uk/gp/help/customer/display.html/ref=hp_rel_topic?ie=UTF8&nodeId=548524#conditions_vente')
    assert merchant.save, merchant.errors.full_messages.join(",")
  end

end
