require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :countries
  
  setup do
    @user = users(:elarch)
  end

  test "it should create user and send confirmation email" do
    user = User.new(
      :email => "user@gmail.com", 
      :password => "password", 
      :password_confirmation => "password",
      :first_name => "John",
      :last_name => "Doe",
      :civility => User::CIVILITY_MR,
      :birthdate => '1973-01-01',
      :nationality_id => countries(:france).id,
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
  
  test "it should check user age" do
    user = User.new(
      :email => "user@gmail.com", 
      :password => "password", 
      :password_confirmation => "password",
      :first_name => "John",
      :last_name => "Doe",
      :civility => User::CIVILITY_MR,
      :nationality_id => countries(:france).id,
      :birthdate => 10.years.ago)
    assert !user.save
    assert_equal I18n.t('users.invalid_birthdate'), user.errors.full_messages.first
  end
  
  test "user should be male or female" do
    assert @user.male?
    assert !@user.female? 
  end
  
  test "it should destroy dependent objects" do
    user_id = @user.id
    assert_equal 1, Address.find_all_by_user_id(user_id).count
    assert_equal 2, Phone.find_all_by_user_id(user_id).count
    @user.destroy
    assert_equal 0, Address.find_all_by_user_id(user_id).count
    assert_equal 0, Phone.find_all_by_user_id(user_id).count    
  end
  
end
