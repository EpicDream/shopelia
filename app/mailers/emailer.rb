class Emailer < ActionMailer::Base
  
  def password_reset flinker
    @resource = flinker
    mail(:to => @email,
  		   :subject => "Reset Password",
  	     :from => "Flink Fashion Link <hello@flink.io>")
  end
  
  def flinkhq_mention comment
    @comment = comment
    mail(:to => 'staff@flink.io',
  		   :subject => 'flinkHQ mentionné dans un commentaire',
  	     :from => 'The genius at backend <genius@flink.io>')
  end
  
end
