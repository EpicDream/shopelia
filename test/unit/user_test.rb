# -*- encoding : utf-8 -*-
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :countries, :psps
  
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
      :ip_address => '127.0.0.1',
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
      :ip_address => '127.0.0.1',
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
  
  test "it should create and update leetchi user" do
    @user.destroy # cleanup
    allow_remote_api_calls
    VCR.use_cassette('user') do
      user = User.new(
        :email => "elarch@gmail.com", 
        :password => "tototo", 
        :password_confirmation => "tototo",
        :first_name => "Eric",
        :last_name => "Larchevêque",
        :civility => User::CIVILITY_MR,
        :nationality_id => countries(:france).id,
        :ip_address => '127.0.0.1',
        :birthdate => '1973-09-30')
      assert user.save, user.errors.full_messages.join(",")
      
      assert user.leetchi, "Leetchi user not created"

      # Request leetchi user to check data integrity
      leetchi_user = Leetchi::User.details(user.leetchi.remote_user_id)
      assert_equal user.email, leetchi_user['Email']
      assert_equal user.first_name, leetchi_user['FirstName']
      assert_equal user.last_name, leetchi_user['LastName']
      assert_equal user.nationality.iso, leetchi_user['Nationality']
      assert_equal user.birthdate.to_i, leetchi_user['Birthday']
      assert_equal "NATURAL_PERSON", leetchi_user['PersonType']
      assert !leetchi_user['IsStrongAuthenticated']
      assert leetchi_user['CanRegisterMeanOfPayment']

      # Update
      user.update_attributes(:birthdate => '1970-09-30')
      
      # Request leetchi user to verify bithdate has been updated
      leetchi_user = Leetchi::User.details(user.leetchi.remote_user_id)
      assert_equal user.birthdate.to_i, leetchi_user['Birthday'].to_i
    end
  end

  test "it should manage leetchi api failure at user creation" do
    allow_remote_api_calls
    VCR.use_cassette('user_fail') do
      assert_difference('User.count', 0) do
        @user = User.create(
          :email => "willfail@gmail.com", 
          :password => "tototo", 
          :password_confirmation => "tototo",
          :first_name => "Joe",
          :last_name => "Fail",
          :civility => User::CIVILITY_MR,
          :nationality_id => countries(:france).id,
          :ip_address => '127.0.0.1',
          :birthdate => '1973-09-30')
        assert !@user.persisted?, "User creation should have failed"
      end
      
      assert @user.errors.present?
      errors = Psp::LeetchiWrapper.extract_errors @user
      assert_equal "remote", errors["origin"]
      assert_equal 0, errors["error_code"]
      assert_equal "Api failure", errors["user_message"]
      assert_equal "Api failure", errors["message"]
      assert_equal "SystemError", errors["type"]
    end
  end

  test "it should manage leetchi api failure at user update" do
    allow_remote_api_calls
    VCR.use_cassette('user_fail') do
      user = User.new(
        :email => "willfail_later@gmail.com", 
        :password => "tototo", 
        :password_confirmation => "tototo",
        :first_name => "Joe",
        :last_name => "Fail",
        :civility => User::CIVILITY_MR,
        :nationality_id => countries(:france).id,
        :ip_address => '127.0.0.1',
        :birthdate => '1973-09-30')
      assert user.save

      user.update_attributes(:birthdate => '1970-09-30')
      assert user.errors.present?
      assert_equal DateTime.parse('1973-09-30'), user.reload.birthdate
      
      errors = Psp::LeetchiWrapper.extract_errors user
      assert_equal "remote", errors["origin"]
      assert_equal 0, errors["error_code"]
      assert_equal "Api failure", errors["user_message"]
      assert_equal "Api failure", errors["message"]
      assert_equal "SystemError", errors["type"]
    end
  end
  
end
