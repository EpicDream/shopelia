require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "it should create user and send confirmation email" do
    user = User.new(
      :email => "user@gmail.com", 
      :password => "password", 
      :password_confirmation => "password",
      :first_name => "John",
      :last_name => "Doe")
    assert user.save
    assert_equal "John", user.first_name
    assert_equal "Doe", user.last_name
    
    puts user.inspect
    mail = ActionMailer::Base.deliveries.last
    assert mail.present?
    assert_equal "user@gmail.com", mail.to[0]
  end
  
end
