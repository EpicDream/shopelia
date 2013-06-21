# -*- encoding : utf-8 -*-
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users, :countries, :payment_cards
  
  setup do
    @user = users(:elarch)
  end

  test "it should create user" do
    user = User.new(
      :email => "user@gmail.com",
      :first_name => "John",
      :last_name => "Doe",
      :ip_address => '127.0.0.1',
      :addresses_attributes => [ {
        :code_name => "Office",
        :phone => "0646403619",
        :address1 => "21 rue d'Aboukir",
        :zip => "75002",
        :city => "Paris",
        :country_id => countries(:france).id,
        } ],
      :payment_cards_attributes => [ {
          :number => "4970100000000154",
          :exp_month => "02",
          :exp_year => "2017",
          :cvv => "123"
        } ]
      )
  
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
    assert_equal 1, user.payment_cards.count
    
    assert !user.has_password?
  end

  test "it should fail user creation with missing info" do
    user = User.new(:email => "user@gmail.com")
    assert !user.save

    mail = ActionMailer::Base.deliveries.last
    assert !mail.present?, "a confirmation email shouldn't have been sent"
  end

  test "it should fail user creation with a bad address" do
    user = User.create(
      :email => "user@gmail.com", 
      :first_name => "John",
      :last_name => "Doe",
      :ip_address => '127.0.0.1',
      :addresses_attributes => [ {
        :code_name => "Office",
        :phone => "0646403619",        
        :address1 => "21 rue d'Aboukir"
      } ] )
  
    assert !user.persisted?
    assert_equal "Le code postal doit être renseigné,La ville doit être renseignée", user.errors.full_messages.join(",")

    mail = ActionMailer::Base.deliveries.last
    assert !mail.present?, "a confirmation email shouldn't have been sent"
  end

  test "it should create infinitely user with email test@shopelia.fr" do
    User.create(
      :email => "test@shopelia.fr", 
      :first_name => "John",
      :last_name => "Doe",
      :ip_address => '127.0.0.1')
    user = User.new(
      :email => "test@shopelia.fr", 
      :first_name => "John",
      :last_name => "Doe",
      :ip_address => '127.0.0.1')
    assert user.save
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
    @user.civility = User::CIVILITY_MR
    assert @user.male?
    assert !@user.female? 
  end
  
  test "it should destroy dependent objects" do
    user_id = @user.id
    assert_equal 2, Address.find_all_by_user_id(user_id).count
    @user.destroy
    assert_equal 0, Address.find_all_by_user_id(user_id).count
  end
  
  test "it should have password" do
    assert @user.has_password?
  end
  
  test "it should check validity of pincode" do
    assert @user.has_pincode?
    @user.pincode = nil
    assert !@user.has_pincode?
  end
  
  test "it should verify user by pincode" do
    assert !@user.verify({ "pincode" => "4567" })
    assert @user.verify({ "pincode" => "1234" })
    @user.pincode = ""
    assert !@user.verify({ "pincode" => "" })
  end
  
  test "it should verify user by cc number" do
    assert @user.verify({ "cc_num" => "0154", "cc_month" => "02", "cc_year" => "15" })
    assert !@user.verify({ "cc_num" => "0154", "cc_month" => "05", "cc_year" => "15" })
  end
  
  test "verification failure should create a log" do
    assert_difference('UserVerificationFailure.count', 1) do
      @user.verify({ "pincode" => "4567" })
    end
  end
  
  test "verification success should clear log" do
    @user.verify({ "pincode" => "4567" })
    assert_difference('UserVerificationFailure.count', -1) do
      @user.verify({ "pincode" => "1234" })
    end
  end
  
  test "it shouldn't resend confirmation when user is updated" do
    @user.update_attribute :pincode, "4567"
    mail = ActionMailer::Base.deliveries.last
    assert !mail.present?, "a confirmation email shouldn't have been sent"
  end
  
  test "it should mark user as unconfirmed and resend confirmation email when email is changed" do
    @user.update_attribute :email, "elarch2@gmail.com"
    assert !@user.confirmed?
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?, "a confirmation email should have been sent"
  end
  
  test "it should create and update leetchi user" do
    @user.destroy
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
      assert user.leetchi_created?, "Leetchi user not created"

      # Request leetchi user to check data integrity
      leetchi_user = Leetchi::User.details(user.leetchi_id)
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
      leetchi_user = Leetchi::User.details(user.leetchi_id)
      assert_equal user.birthdate.to_i, leetchi_user['Birthday'].to_i
    end
  end

  test "it should return false when password or password confirmation are blanks" do
    user = User.create(
        :email => "willfail@gmail.com",
        :password => "",
        :password_confirmation => "",
        :first_name => "Joe",
        :last_name => "Fail",
        :civility => User::CIVILITY_MR,
        :nationality_id => countries(:france).id,
        :ip_address => '127.0.0.1',
        :birthdate => '1973-09-30')
    assert !user.password_match?
    errors = user.errors
    assert_equal ["doit être rempli(e)"],  errors[:password]
    assert_equal ["doit être rempli(e)"],  errors[:password_confirmation]
  end

  test "it should return false when password confirmation doesn't match" do
    user = User.create(
        :email => "willfail@gmail.com",
        :password => "toto",
        :password_confirmation => "merguez",
        :first_name => "Joe",
        :last_name => "Fail",
        :civility => User::CIVILITY_MR,
        :nationality_id => countries(:france).id,
        :ip_address => '127.0.0.1',
        :birthdate => '1973-09-30')
    assert !user.password_match?
    errors = user.errors
    assert_equal ["ne concorde pas avec le mot de passe"],  errors[:password_confirmation]
  end

  test "it should return true password and password confirmation are the same" do
    user = User.create(
        :email => "willpass@gmail.com",
        :password => "merguez",
        :password_confirmation => "merguez",
        :first_name => "Joe",
        :last_name => "Fail",
        :civility => User::CIVILITY_MR,
        :nationality_id => countries(:france).id,
        :ip_address => '127.0.0.1',
        :birthdate => '1973-09-30')
    assert user.password_match?
  end
  
  test "it should set name" do
    assert_equal "Eric Larchevêque", @user.name
  end
  
end
