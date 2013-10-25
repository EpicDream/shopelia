# -*- encoding : utf-8 -*-
namespace :shopelia do
  namespace :georges do
    
    desc "Autoreply devices waiting for answer for more than one minute"
    task :autoresponder => :environment do
      Device.where(pending_answer:true,autoreplied:false).each do |device|
        last_message = device.messages.last
        if last_message.created_at.to_i < Time.now.to_i - 60
          message = Message.new(content:"J'ai bien reçu votre demande, je suis en train de m'en occuper. Je reviens vers vous rapidement. Merci pour votre patience.",device_id:device.id,autoreply:true)
          Push.send_message message
          device.update_attribute :autoreplied, true
        end
      end
    end
  end
end
