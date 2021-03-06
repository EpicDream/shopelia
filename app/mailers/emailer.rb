class Emailer < ActionMailer::Base
  
  def password_reset flinker
    @resource = flinker
    mail(:to => @email,
  		   :subject => "Reset Password",
  	     :from => "Flink Fashion Link <hello@flink.io>")
  end
  
  def after_signup flinker
    @flinker = flinker
    #WAITING for email welcome template...
  end
  
  def flinkhq_mention comment
    @comment = comment
    mail(:to => 'staff@flink.io',
  		   :subject => 'flinkHQ mentionné dans un commentaire',
  	     :from => '2130 after JC<apocalypse@flink.io>')
  end
  
  def newsletter flinker, test=false, date=Date.today
    I18n.locale = flinker.lang_iso == "fr_FR" ? :fr : :en
    newsletter = Newsletter.last

    @subject = newsletter.send("subject_#{I18n.locale}")
    @header_logo_img = Newsletter::HEADER_LOGO_URL
    @header_img = newsletter.header_img_url
    @footer_img = newsletter.footer_img_url
    
    @favorites = newsletter.favorites
    @footer_look_uuid = newsletter.look_uuid
    @trendsetters = Flinker.recommendations_for(flinker)
    
    headers['X-Mailjet-Campaign'] = test ? "Weekly Newsletter Test - #{I18n.locale}" : "Weekly Newsletter #{date} - #{I18n.locale}"
    headers['X-Mailjet-DeduplicateCampaign'] = 'y' unless test
    
    mail(:to => flinker.email,
  		   :subject => @subject,
  	     :from => 'Flink<newsletter@flink.io>')
  end
  
end
