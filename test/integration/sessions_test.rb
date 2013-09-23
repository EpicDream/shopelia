# -*- encoding : utf-8 -*-
require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest

  setup do
    sign_out
  end

  test "should register a new user" do
    sign_up

    assert_equal current_path, home_index_path
    assert page.has_content?('Eric Test')
  end

  test "should login user" do
    sign_in

    assert_equal current_path, home_index_path
    assert page.has_content?('Eric Larcheveque')
  end

  test "should send password instructions and change it" do
    ensure_on connect_path
    click_link "Mot de passe oublié"
    fill_in "Email", with:"elarch@gmail.com"
    click_button "Recevoir les instructions"

    assert_equal 1, ActionMailer::Base.deliveries.count

    mail = ActionMailer::Base.deliveries.first.decoded
    token = mail.match(/reset_password_token=([^\"]+)/)[1]

    visit "/users/password/edit?reset_password_token=#{token}"
    fill_in "Mot de passe", with:"nouveau"
    fill_in "Confirmation", with:"nouveau"
    click_button "Valider"

    assert_equal current_path, home_index_path
    assert page.has_content?('Eric Larcheveque')    

    sign_out
    sign_in "elarch@gmail.com", "nouveau"

    assert page.has_content?('Eric Larcheveque')    
  end
end