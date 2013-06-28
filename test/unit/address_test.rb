# -*- encoding : utf-8 -*-
require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :users, :countries, :addresses, :orders, :merchants, :products

  setup do
    @user = users(:elarch)
    @address = addresses(:elarch_neuilly)
  end

  test "it should create address and manage default property attribution" do
    address = Address.new(
      :user_id => @user.id,
      :phone => "0646403619",
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :is_default => true,
      :country_iso => "fr")
    
    assert address.save, address.errors.full_messages.join(",")
    assert_equal "Eric", address.first_name
    assert_equal "Larcheveque", address.last_name    
    assert address.is_default?, "New address must be default"
    assert !@address.reload.is_default?, "Old address musn't be default"

    address.destroy
    addresses(:elarch_vignoux).destroy
    assert @address.reload.is_default, "Last standing address should be default"    
  end

  test "it should create address with first and last name" do
    address = Address.new(
      :user_id => @user.id,
      :phone => "0646403619",
      :first_name => "Toto",
      :last_name => "France",
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :is_default => true,
      :country_iso => "fr")
    
    assert address.save, address.errors.full_messages.join(",")
    assert_equal "Toto", address.first_name
    assert_equal "France", address.last_name    
  end

  test "a new address must not be default if not specified" do
    address = Address.new(
      :user_id => users(:elarch).id,
      :phone => "0646403619",
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :country_id => countries(:france).id)
    
    assert address.save, address.errors.full_messages.join(",")
    assert !address.is_default?, "New address must not be default"
    assert @address.reload.is_default?, "Old address must still be default"
  end

  test "a first address must be default" do
    address = Address.new(
      :user_id => users(:thomas).id,
      :phone => "0646403619",
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :country_id => countries(:france).id)
    
    assert address.save, address.errors.full_messages.join(",")
    assert address.is_default?, "New address must default"
  end
  
  test "it should create address from reference" do
    VCR.use_cassette('places_api') do  
      address = Address.new(
        :user_id => users(:elarch).id,
        :phone => "0646403619",        
        :reference => "CjQjAAAAPtgCbee5jsEkoWoc6apT3qFBYmWlxcVOPrwUBoQ5Pqv8ExTxyh-M--tsL8QAT8xCEhBo2z7K3wdT4K6S7smh--ZIGhTCBtyjxjD5fBNcR15jutp7SZA2Fw")

      assert address.save
      assert_equal "21 Rue d'Aboukir", address.address1
      assert_equal "75002", address.zip
      assert_equal "Paris", address.city
      assert_equal countries(:france).id, address.country_id
    end
  end
  
  test "it should fail all non completed orders attached to a destroyed address" do
    order = orders(:elarch_rueducommerce)
    assert_equal :initialized, order.state
    @address.destroy
    
    assert_equal :failed, order.reload.state
    assert_equal "user", order.error_code
    assert_equal "address_destroyed", order.message
  end

end
