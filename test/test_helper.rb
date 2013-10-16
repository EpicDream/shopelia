ENV['CODECLIMATE_REPO_TOKEN'] = "ca2789d1f39a05e6a153ca9b548f617909b6b9d7f86721714af809b9520ce3ef"
ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'sidekiq/testing'
require 'capybara/rails'

Dir["#{Rails.root}/test/helper/*.rb"].each {|f| puts f ; require f}

class ActiveSupport::TestCase
  fixtures :all

  setup do
    $sms_gateway_count = 0
    ENV["API_KEY"] = developers(:prixing).api_key
    ActionMailer::Base.deliveries.clear
    File.delete(MangoPayDriver::CONFIG) if File.exist?(MangoPayDriver::CONFIG)
    EventsWorker.clear
  end

  def json_response
    JSON.parse @response.body
  end

  def prepare_master_cashfront_account value=10000
    MangoPayDriver.create_master_account  
    card = { number:"4970100000000154", exp_month:"12", exp_year:"2020", cvv:"123" }
    contribution = MangoPayDriver.credit_master_account card, value if value > 0
  end
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include CommonHelper
  include SessionsHelper

  setup do
    Capybara.javascript_driver = :webkit
  end
end
