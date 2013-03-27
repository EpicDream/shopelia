require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :developers

  setup do
    ENV["API_KEY"] = developers(:prixing).api_key
  end
  
  def json_response
    JSON.parse @response.body
  end
  
end
