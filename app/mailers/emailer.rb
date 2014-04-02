class Emailer < ActionMailer::Base
  def password_reset flinker
    @resource = flinker
    mail(:to => @email,
  		   :subject => "Reset Password",
  	     :from => "Flink Fashion Link <hello@flink.io>")
  end
end
