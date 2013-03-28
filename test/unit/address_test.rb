require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :users, :phones, :countries, :addresses

  setup do
    @address = addresses(:elarch_neuilly)
  end

  test "it should create address" do
    address = Address.new(
      :user_id => users(:elarch).id,
      :address1 => "21 rue d'Aboukir",
      :zip => "75002",
      :city => "Paris",
      :is_default => true,
      :country_id => countries(:france).id)
    
    assert address.save, address.errors.full_messages.join(",")
    assert address.is_default?, "New address must default"
    assert !@address.reload.is_default?, "Old address musn't be default"
  end
  
  test "it should destroy dependent objects" do
    address_id = @address.id
    assert_equal 1, Phone.find_all_by_address_id(address_id).count
    @address.destroy
    assert_equal 0, Phone.find_all_by_address_id(address_id).count   
  end

end
