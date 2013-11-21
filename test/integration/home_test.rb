# -*- encoding : utf-8 -*-
require 'test_helper'

class HomeTest < ActionDispatch::IntegrationTest

  test "should send email with app download link" do
    visit "/"
    find("#get-link").click
    fill_in "send-link-input", with:"elarch@gmail.com"

    assert_difference "ActionMailer::Base.deliveries.count" do
      click_button "send-link-btn"
    end
  end
end