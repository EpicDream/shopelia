require 'test_helper'

class DeviseOverride::ConfirmationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    request.env['devise.mapping'] = Devise.mappings[:user]
    @user = users(:elarch)
    sign_in @user
  end

  test "it should render resend confirmation if confirmation token is invalid" do
    assert_equal @controller.class.superclass, Devise::ConfirmationsController
    @user.confirmation_token = ""
    @user.save
    get :show, confirmation: @user.confirmation_token
    assert_template :new
  end

  test "it should render complete profile template if it's the right confirmation token" do
    sign_out @user
    user = User.create!(email:"toto@toto.fr", first_name:"Eric", last_name:"Larch", ip_address:"192.168.1.1", developer_id:developers(:prixing).id)
    get :show, confirmation_token: user.reload.confirmation_token
    assert_template :show
  end

  test "it should not update user attributes and redirect to show" do
    sign_out @user
    user = User.create!(email:"toto@toto.fr", first_name:"Eric", last_name:"Larch", ip_address:"192.168.1.1", developer_id:developers(:prixing).id)
    get :show, confirmation_token: user.reload.confirmation_token
    put :confirm, user: {}
    assert_template :show
  end

  test "it should update user attributes" do
    sign_out @user
    user = User.create!(email:"toto@toto.fr", first_name:"Eric", last_name:"Larch", ip_address:"192.168.1.1", developer_id:developers(:prixing).id)
    get :show, confirmation_token: user.reload.confirmation_token
    put :confirm, user: { password: "merguez", password_confirmation: "merguez",civility: "1" , birthdate: "05/01/1980", nationality_id: countries(:morocco).id,confirmation_token: user.reload.confirmation_token}
    assert user.reload.valid_password?("merguez")
  end



end

