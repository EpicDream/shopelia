# -*- encoding : utf-8 -*-

namespace :shopelia do
  namespace :georges do
    
    desc "Autoreply devices waiting for answer for more than one minute"
    task :autoresponder => :environment do
      Device.where(pending_answer:true,autoreplied:false).each do |device|
        last_message = device.messages.last
        if last_message.created_at.to_i < Time.now.to_i - 60
          message = Message.new(content:"Je m'occupe de votre demande et reviens vers vous au plus vite ! Merci de votre patience.",device_id:device.id,autoreply:true)
          Push.send_message message
          device.update_attribute :autoreplied, true
        end
      end
    end

    desc "Distribute 10€ Amazon gift to new users interacting with Georges"
    task :welcome_gift => :environment do
      Leftronic.new.push_tts "Attention ! Envoi imminent des chèques cadeaux de 10 euros"
      amazon = Merchant.find_by_domain("amazon.fr")
      shopelia = Developer.find_by_name("Shopelia")
      count = 0
      Device.where("push_token is not null and created_at > ? and created_at < ?", 2.days.ago, Date.today).each do |device|
        next if device.cashfront_rules.count > 0
        next if device.user && device.user.orders.completed.count > 0
        next if device.pending_answer?
        first_message = device.messages.where(from_admin:nil).order(:created_at).first
        next if first_message.nil? || first_message.created_at.to_date != Date.yesterday
        last_message = device.messages.where(from_admin:nil).order(:created_at).last
        next if last_message.created_at.to_i > Time.now.to_i - 3600
        CashfrontRule.create!(
          merchant_id:amazon.id,
          rebate_percentage:50,
          developer_id:shopelia.id,
          device_id:device.id,
          max_orders_count:1,
          max_rebate_value:10)
        message = Message.new(content:"Bonjour ! Suite à notre dernier échange, j'ai le plaisir de vous offrir un chèque cadeau de 10€ utilisable immédiatement sur toute la boutique Amazon. N'hésitez pas à me contacter pour toute question :)",device_id:device.id)
        Push.send_message message
        count += 1
      end
      puts "Sent #{count} Amazon 10€ vouchers"
    end

    desc "Reminder for all holders of 10€ Amazon gift"
    task :welcome_gift_reminder => :environment do
      amazon = Merchant.find_by_domain("amazon.fr")
      shopelia = Developer.find_by_name("Shopelia")
      CashfrontRule.where(merchant_id:amazon.id,developer_id:shopelia.id).where("device_id is not null").each do |rule|
        next if rule.created_at.to_i > 3.days.ago.to_i 
        next if rule.device.user && rule.device.user.orders.completed.count > 0
        message = Message.new(content:"Bonjour :) Votre chèque cadeau de 10€ sur la boutique Amazon vous attend toujours. C'est le moment d'en profiter !",device_id:rule.device.id)
        Push.send_message message
      end
    end
  end
end
