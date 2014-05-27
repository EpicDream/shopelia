class NewsletterWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :newsletter, retry:false
  
  def perform
    Rails.logger = Logger.new('log/newsletter.log')
    Flinker.where(newsletter:true).find_in_batches { |flinkers|
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
