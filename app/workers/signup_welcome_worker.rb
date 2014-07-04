class SignupWelcomeWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :emails, retry:false
  
  def perform flinker_id
    flinker = Flinker.find(flinker_id)
    Emailer.after_signup(flinker)
  end
  
end
