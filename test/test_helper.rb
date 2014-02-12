ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'sidekiq/testing'

Dir["#{Rails.root}/test/helper/*.rb"].each {|f| require f}
Sidekiq::Testing.fake!


class ActiveSupport::TestCase
  fixtures :all
  
  setup do
    FollowNotificationWorker.stubs(:perform_in) #cause wait in test env, sidekiq bug?
    ENV["API_KEY"] = developers(:prixing).api_key
  end

  def json_response
    JSON.parse @response.body
  end

  def assert_change object, attribute, test_on=:"!="
    before = object.send(attribute)
    yield
    after = object.reload.send(attribute)
    assert after.send(test_on, before)
  end
  
end

require 'mocha/setup'