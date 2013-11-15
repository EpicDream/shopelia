# -*- encoding : utf-8 -*-
require 'test_helper'

class Api::V1::GeorgesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @device = devices(:mobile)
  end

  test "it should send status" do
    GeorgesStatus.set GeorgesStatus::SLEEPING

    get :status, format: :json
    assert_response :success
    assert_equal GeorgesStatus::SLEEPING, json_response["status"]
    assert_match /dort/, json_response["message"]
  end
end