require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :users

  setup do
    @user = users(:elarch)
  end

  test "should get edit page" do
    sign_in @user
    get :edit, id: @user, format: :json
    assert_response :success
  end

  test "should not get edit page when not signed in " do
    get :edit, id: @user, format: :json
    assert_response :unauthorized
  end

  test "should get the current_user when signed in" do
    sign_in @user
    get :edit, id: @user, format: :json
    assert @user.email, json_response["user"]["email"]
  end

  test "should update user password" do
    sign_out @user
    user = User.create!(email:"toto@toto.fr", first_name:"Eric", last_name:"Larch", ip_address:"192.168.1.1")
    sign_in user
    put :update, id: user, user: { password:"tititi", password_confirmation:"tititi" }, format: :json
    assert_response 204
    assert user.reload.valid_password?("tititi")
  end


  test "should render edit page with errors user isn't updated (JSON)" do
    sign_out @user
    user = User.create!(email:"toto@toto.fr", first_name:"Eric", last_name:"Larch", ip_address:"192.168.1.1")
    sign_in user
    put :update, id: user, user: { password:"tititi", password_confirmation:"merguez" }, format: :json
    assert_response 422
  end

  test "should render edit page with errors user isn't updated (HTMl)" do
    sign_out @user
    user = User.create!(email:"toto@toto.fr", first_name:"Eric", last_name:"Larch", ip_address:"192.168.1.1")
    sign_in user
    put :update, id: user, user: { password:"tititi", password_confirmation:"merguez" }, format: :html
    assert_template "edit"
  end


end