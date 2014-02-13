# -*- encoding : utf-8 -*-
require 'csv'

namespace :mailchimp do
  namespace :extract do
    desc "Export emails and usernames for mailchimp"
    task :emails => :environment do
      flinkers = Flinker.all #where(:is_publisher => false)
      timestamp = Time.now.to_i
      CSV.open("#{Rails.root}/tmp/mailchimp/#{timestamp}_emails_and_usernames.csv", "wb")  do |csv|
        csv << ["email","username"]
        flinkers.each do |flinker|
          csv << [flinker.email,flinker.username]
        end
      end
    end
  end
end