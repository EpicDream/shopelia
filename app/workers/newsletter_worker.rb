class NewsletterWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :newsletter, retry:false
  
  def perform
    timestamp = Date.today
    Flinker.where(newsletter:true).where("email !~ '@flink'").find_in_batches { |flinkers|
      flinkers.each { |flinker|
        begin
          Emailer.newsletter(flinker, false, timestamp).deliver
        rescue => e
          Sidekiq.logger.error("[#{Time.now}][#{flinker.email}][#{e.inspect}]\n#{e.backtrace.join("\n")}\n")
        end
      }
    }
  end
end
