require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :users, :phones, :countries, :addresses

  setup do
    @address = addresses(:elarch_neuilly)
  end

  test "it should create address and manage default property attribution" do
    address = Address.new(
      :user_id => users(:elarch).id,
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :is_default => true,
      :country_id => countries(:france).id)
    
    assert address.save, address.errors.full_messages.join(",")
    assert address.is_default?, "New address must be default"
    assert !@address.reload.is_default?, "Old address musn't be default"

    address.destroy
    assert @address.reload.is_default, "Last standing address should be default"    
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
      :user_id => users(:manu).id,
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

end
