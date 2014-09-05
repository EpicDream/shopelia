require 'test_helper'

class ApnsNotificationWorkerTest < ActiveSupport::TestCase

  setup do
  end

  test "send apns notif to all frenches flinkers with push token" do
    betty_device = Device.create!(push_token: "TOKEN1", flinker_id: flinkers(:betty).id)
    lilou_device = Device.create!(push_token: "TOKEN2", flinker_id: flinkers(:lilou).id)
    notif = ApnsNotification.create!(text_en: "Hello", text_fr: "Bonjour")
    
    Sidekiq::Testing.inline! do
      Flink::Push.expects(:deliver_by_batch).with("Bonjour", [betty_device], {"notification_id" => notif.id.to_s}).times(1)
      Flink::Push.expects(:deliver_by_batch).with("Hello", [lilou_device], {"notification_id" => notif.id.to_s}).times(1)
      
      notif.send_to_all_flinkers
    end
  end
  
  test "send apns notif with target look" do
    look = looks(:agadir)
    apns_test_with_target("Look", look.id, "looks", look.uuid)
  end
  
  test "send apns notif with target flinker" do
    flinker = flinkers(:betty)
    apns_test_with_target("Flinker", flinker.id, "flinkers", flinker.id.to_s)
  end

  test "send apns notif with target hashtag" do
    hashtag = Hashtag.find_or_create_by_name("fashion")
    apns_test_with_target("Hashtag", hashtag.id, "hashtags", hashtag.name)
  end
  
  test "send apns notif with target theme" do
    theme = themes(:mode)
    apns_test_with_target("Theme", theme.id, "themes", nil)
  end

  private
  
  def apns_test_with_target klass_name, resource_id, link_kind, identifier
    betty_device = Device.create!(push_token: "TOKEN1", flinker_id: flinkers(:betty).id)
    lilou_device = Device.create!(push_token: "TOKEN2", flinker_id: flinkers(:lilou).id)
    notif = ApnsNotification.create!(text_en: "Hello", text_fr: "Bonjour", resource_klass_name: klass_name, resource_id: resource_id)

    metadata = {"link_kind" => link_kind, "identifier" => identifier, "notification_id" => notif.id.to_s }
    Sidekiq::Testing.inline! do
      Flink::Push.expects(:deliver_by_batch).with("Hello", [lilou_device], metadata).times(1)
      Flink::Push.expects(:deliver_by_batch).with("Bonjour", [betty_device], metadata).times(1)
      
      notif.send_to_all_flinkers
    end
    
  end
end
