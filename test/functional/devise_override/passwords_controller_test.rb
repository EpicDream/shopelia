require 'test_helper'

class DeviseOverride::PasswordsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test "it should sent password reset instructions by ajax" do
    xhr :post, :create, user:{email:"elarch@gmail.com"}

    assert_template "devise/passwords/success"
  end

  test "it should fail password reset instructions by ajax" do
    xhr :post, :create, user:{email:"toto@gmail.com"}

    assert_template "devise/passwords/error"
  end
end