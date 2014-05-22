class SignupWelcomeWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :emails, retry:false
  
  def perform flinker_id
    flinker = Flinker.find(flinker_id)
    flinkHQ = Flinker.where(username:'flinkhq').first
    FlinkerFollow.create(flinker_id:flinkHQ.id, follow_id:flinker.id)
    Emailer.after_signup(flinker)
  end
  
end
