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

    desc "Distribute 10€ Amazon gift to new users"
    task :welcome_gift => :environment do
      amazon = Merchant.find_by_domain("amazon.fr")
      shopelia = Developer.find_by_name("Shopelia")
      Device.where("push_token is not null and created_at > ? and created_at < ?", 10.days.ago, Date.today).each do |device|
        next if device.cashfront_rules.count > 0
        CashfrontRule.create!(
          merchant_id:amazon.id,
          rebate_percentage:50,
          developer_id:shopelia.id,
          device_id:device.id,
          max_rebate_value:10)
        message = Message.new(content:"Bonjour ! Pour vous souhaiter la bienvenue sur Shopelia, j'ai le plaisir de vous offrir un chèque cadeau de 10€ utilisable immédiatement sur toute la boutique Amazon. N'hésitez pas à me contacter pour toute question :)",device_id:device.id)
        Push.send_message message
      end
    end
  end
end
