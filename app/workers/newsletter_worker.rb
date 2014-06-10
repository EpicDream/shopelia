class NewsletterWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :newsletter, retry:false
  
  def perform
    Flinker.where(newsletter:true).where("email !~ '@flink'").find_in_batches { |flinkers|
      flinkers.each { |flinker|
        begin
          Emailer.newsletter(flinker).deliver
        rescue => e
          Sidekiq.logger.error("[#{Time.now}][#{flinker.email}][#{e.inspect}]\n#{e.backtrace.join("\n")}\n")
        end
      }
    }
  end
end
