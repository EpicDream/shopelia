require 'test_helper'

class PhoneTest < ActiveSupport::TestCase
  fixtures :users, :addresses, :phones
  
  test "it should create a phone for a user" do
    phone = Phone.new(
      :user_id => users(:elarch).id,
      :number => '0941412020',
      :address_id => addresses(:elarch_neuilly),
      :line_type => Phone::LAND)
    assert phone.save
  end

  test "it should create a mobile phone without address" do
    phone = Phone.new(
      :user_id => users(:elarch).id,
      :number => '0941412020',
      :line_type => Phone::MOBILE)
    assert phone.save
  end

  test "it should'nt create a land phone without address" do
    phone = Phone.new(
      :user_id => users(:elarch).id,
      :number => '0941412020',
      :line_type => Phone::LAND)
    assert !phone.save
  end

  test "it should ensure phone unicity" do
    phone = Phone.new(
      :user_id => users(:elarch).id,
      :number => '0646403619',
      :line_type => Phone::MOBILE)
    assert !phone.save
  end

end
