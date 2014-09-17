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
    Flinker.any_instance.stubs(:remove_from_index!)
    Flinker.any_instance.stubs(:index!)
    ActiveRecord::Base.connection.execute("CREATE EXTENSION intarray;")
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
  
  def follow publisher, flinker=@flinker
    FlinkerFollow.create!(flinker_id:flinker.id, follow_id:publisher.id)
  end
  
  def like flinker, looks
    looks.map do |look|
      FlinkerLike.create(flinker_id:flinker.id, resource_type:FlinkerLike::LOOK, resource_id:look.id)
    end
  end

  def populate_looks_for publishers
    Look.destroy_all
    publishers.each do |publisher|
      5.times { |n| new_look_for(publisher, at: (n + 1).day.ago) }
      5.times { |n| new_look_for(publisher, at: (n + 1).months.ago) }
    end
  end

  def new_look_for publisher, at: Time.now
    look = Look.create!(
      name:"Article#{at.to_i}",
      flinker_id:publisher.id,
      published_at:at - 4.days,
      flink_published_at:at,
      is_published:true,
      url:"http://www.leblogdebetty.com/article")
    look.created_at =  at - 4.days
    look.updated_at =  at - 4.days
    look.save!
  end
  
  def set_env_user_agent build=1
    value = "flink:os[iOS]:build[#{build}]:version[1.0.1]:os_version[4.4]:phone[Samsung Galaxy]:uuid[#{devices(:mobile).uuid}]:dev[2]"
    ENV['HTTP_USER_AGENT'] = value
    @request.env["HTTP_USER_AGENT"] = value if @request
  end
  
end

require 'mocha/setup'