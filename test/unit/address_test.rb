require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :users, :phones, :countries, :addresses

  setup do
    @user = users(:elarch)
    @address = addresses(:elarch_neuilly)
  end

  test "it should create address and manage default property attribution" do
    address = Address.new(
      :user_id => @user.id,
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :is_default => true,
      :country_iso => "fr",
      :phones_attributes => [ {
        :number => "0140404040",
        :line_type => Phone::LAND 
        } ] )
    
    assert address.save, address.errors.full_messages.join(",")
    assert address.is_default?, "New address must be default"
    assert !@address.reload.is_default?, "Old address musn't be default"
    assert_equal 1, address.phones.count

    address.destroy
    addresses(:elarch_vignoux).destroy
    assert @address.reload.is_default, "Last standing address should be default"    
  end

  test "it should fail address creation with an incorrect phone" do
    address = Address.create(
      :user_id => users(:elarch).id,
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :phones_attributes => [ {
        :line_type => Phone::LAND
        } ] )
    
    assert !address.persisted?
    assert_equal "Number can't be blank", address.errors.full_messages.join(",")
  end

  test "a new address must not be default if not specified" do
    address = Address.new(
      :user_id => users(:elarch).id,
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
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :country_id => countries(:france).id)
    
    assert address.save, address.errors.full_messages.join(",")
    assert address.is_default?, "New address must default"
  end
  
  test "it should destroy dependent objects" do
    address_id = @address.id
    assert_equal 1, Phone.find_all_by_address_id(address_id).count
    @address.destroy
    assert_equal 0, Phone.find_all_by_address_id(address_id).count   
  end
  
  test "it should create address from reference" do
    VCR.use_cassette('places_api') do  
      address = Address.new(
        :user_id => users(:elarch).id,
        :reference => "CjQjAAAAPtgCbee5jsEkoWoc6apT3qFBYmWlxcVOPrwUBoQ5Pqv8ExTxyh-M--tsL8QAT8xCEhBo2z7K3wdT4K6S7smh--ZIGhTCBtyjxjD5fBNcR15jutp7SZA2Fw")

      assert address.save
      assert_equal "21 Rue d'Aboukir", address.address1
      assert_equal "75002", address.zip
      assert_equal "Paris", address.city
      assert_equal countries(:france).id, address.country_id
    end
  end

end
