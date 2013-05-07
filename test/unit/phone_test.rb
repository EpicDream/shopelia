require 'test_helper'

class PhoneTest < ActiveSupport::TestCase
  fixtures :users, :addresses, :phones
  
  test "it should create a phone for a user" do
    phone = Phone.new(
      :user_id => users(:elarch).id,
      :number => '0941412020',
      :address_id => addresses(:elarch_neuilly).id,
      :line_type => Phone::LAND)
    assert phone.save, phone.errors.full_messages.join(",")
  end

  test "it should create a mobile phone without address" do
    phone = Phone.new(
      :user_id => users(:elarch).id,
      :number => '0941412020',
      :line_type => Phone::MOBILE)
    assert phone.save, phone.errors.full_messages.join(",")
  end

  test "it should'nt create a land phone without address" do
    phone = Phone.new(
      :user_id => users(:elarch).id,
      :number => '0941412020',
      :line_type => Phone::LAND)
    assert !phone.save, "Phone shouldn't have save"
  end

end
