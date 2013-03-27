require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  fixtures :users, :phones, :countries

  test "it should create address" do
    address = Address.new(
      :user_id => users(:elarch).id,
      :phone_id => phones(:phone_neuilly).id,
      :address1 => "14 bd du Chateau",
      :zip => "92200",
      :city => "Neuilly",
      :country_id => countries(:france).id)
    
    assert address.save
  end

end
