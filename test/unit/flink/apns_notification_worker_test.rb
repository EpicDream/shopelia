require 'test_helper'

class ApnsNotificationWorkerTest < ActiveSupport::TestCase

  setup do
  end

  test "send apns notif to all frenches flinkers with push token" do
    betty_device = Device.create!(push_token: "TOKEN1", flinker_id: flinkers(:betty).id)
    lilou_device = Device.create!(push_token: "TOKEN2", flinker_id: flinkers(:lilou).id)
    notif = ApnsNotification.create!(text_en: "Hello", text_fr: "Bonjour")
    
    Sidekiq::Testing.inline! do
      Flink::Push.expects(:deliver).with("Bonjour", betty_device).times(1)
      Flink::Push.expects(:deliver).with("Hello", lilou_device).times(1)
      
      notif.send_to_all_flinkers
    end
  end
  
end
