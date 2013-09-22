# -*- encoding : utf-8 -*-
require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest

  setup do
    visit "/"
    click_link "Se déconnecter" if page.has_content?("Se déconnecter")
  end

  test "should register a new user" do
    visit "/"
    click_link "Se connecter"
    within "#signup-form" do
      fill_in 'Prénom', with:'Eric'
      fill_in 'Nom', with:'Test'
      fill_in 'Email', with:'elarch-test@gmail.com'
      fill_in 'Mot de passe', with:'merguez'
      click_button "Créer son compte"
    end

    assert page.has_content?('Eric Test')
  end

  test "should login user" do
    visit "/"
    click_link "Se connecter"
    within "#signin-form" do
      fill_in 'Email', with:'elarch@gmail.com'
      fill_in 'Mot de passe', with:'tototo'
      click_button "Se connecter"     
    end

    assert page.has_content?('Eric Larcheveque')
  end
end