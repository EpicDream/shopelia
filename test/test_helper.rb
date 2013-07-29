require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  VCR.configure do |c|
    c.cassette_library_dir = 'test/cassettes'
    c.hook_into :webmock
    c.ignore_localhost = true
    c.default_cassette_options = {
      :record => :new_episodes,
      :serialize_with => :syck,
      :match_requests_on => [:method, VCR.request_matchers.uri_without_param(:ts), :body]
    }
    c.allow_http_connections_when_no_cassette = true
  end

  setup do
    ENV["ALLOW_REMOTE_API_CALLS"] = "0"
    ENV["API_KEY"] = developers(:prixing).api_key
    ActionMailer::Base.deliveries.clear

    # Need this to initialize values
    product_versions(:usbkey).save
    product_versions(:headphones).save
  end

  def json_response
    JSON.parse @response.body
  end
  
  def allow_remote_api_calls
   ENV["ALLOW_REMOTE_API_CALLS"] = "1"
  end

end

