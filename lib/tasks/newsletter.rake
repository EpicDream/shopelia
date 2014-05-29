namespace :flink do
  namespace :newsletter do
    
    desc "Send weekly personalized newsletter to each subscribed flinker"
    task :send => :environment do
      Rails.logger = Logger.new('log/newsletter.log')

      Flinker.where(newsletter:true).where("email !~ '@flink.*'").find_in_batches { |flinkers|
        flinkers.each { |flinker|
          begin
            Emailer.newsletter(flinker).deliver
          rescue => e
            Rails.logger.error("[#{Time.now}][#{flinker.email}][#{e.inspect}]\n#{e.backtrace.join("\n")}\n")
          end
        }
      }
    end
    
  end
end