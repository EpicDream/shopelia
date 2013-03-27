require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :countries

  test "it should create user and send confirmation email" do
    user = User.new(
      :email => "user@gmail.com", 
      :password => "password", 
      :password_confirmation => "password",
      :first_name => "John",
      :last_name => "Doe",
      :addresses_attributes => [ {
        :code_name => "Office",
        :address1 => "21 rue d'Aboukir",
        :zip => "75002",
        :city => "Paris",
        :country_id => countries(:france).id,
        :phones_attributes => [ {
          :number => "0140404040",
          :line_type => Phone::LAND 
          } ] 
        } ],
      :phones_attributes => [ {
          :number => "0640404040",
          :line_type => Phone::MOBILE
          } ] )
          
    assert user.save, user.errors.full_messages.join(",")
    assert_equal "John", user.first_name
    assert_equal "Doe", user.last_name
    
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a confirmation email should have been sent"
    assert_equal "user@gmail.com", mail.to[0]
    assert user.confirmation_sent_at
    
    assert user.authentication_token.present?, "user should have an authentication token"
    assert !user.confirmed?, "user shouldn't be confirmed"
    
    assert_equal 1, user.addresses.count
    assert_equal 1, user.addresses.first.phones.count
    assert_equal 2, user.phones.count
  end
  
end
