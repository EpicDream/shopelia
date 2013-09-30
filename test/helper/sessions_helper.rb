# -*- encoding : utf-8 -*-

module SessionsHelper
  include Capybara::DSL

  def sign_in email='elarch@gmail.com', password='tototo'
    ensure_on connect_path
    within "#signin-form" do
      fill_in 'Email', with:email
      fill_in 'Mot de passe', with:password
      click_button "Se connecter"     
    end
  end

  def sign_up
    ensure_on connect_path
    within "#signup-form" do
      fill_in 'Prénom', with:'Eric'
      fill_in 'Nom', with:'Test'
      fill_in 'Email', with:'elarch-test@gmail.com'
      fill_in 'Mot de passe', with:'merguez'
      click_button "Créer son compte"
    end
  end

  def sign_out
    ensure_on home_index_path
    click_link "Se déconnecter" if page.has_content?("Se déconnecter")
  end
end