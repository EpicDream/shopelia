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
  
  def newsletter flinker
    I18n.locale = flinker.lang_iso == "fr_FR" ? :fr : :en
    @header_logo_img = "http://gallery.mailchimp.com/5c443bc89621ee4e4ce814912/images/aaf3c612-4db0-4664-af20-1c2daf139c28.jpg"
    @header_img = "http://gallery.mailchimp.com/5c443bc89621ee4e4ce814912/images/f2df3ad8-b596-44a1-a09d-1f64eeb0c309.jpg"
    @footer_img = "http://gallery.mailchimp.com/5c443bc89621ee4e4ce814912/images/8428e696-b7df-43a5-81d9-61e34882bdc5.jpg"
    @favorites = Flinker.publishers.last(3) #TODO CHANGE
    @footer_look_uuid = "491c7408" #TODO CHANGE
    @trendsetters = [Flinker.find(5), Flinker.find(3), Flinker.find(2)] #TODO CHANGE
    
    headers['X-Mailjet-Campaign'] = 'newsletter2'
    headers['X-Mailjet-DeduplicateCampaign'] = 'y'
    
    mail(:to => flinker.email,
  		   :subject => 'Tendances fashion de la semaine',
  	     :from => 'Flink<newsletter@flink.io>')
  end
  
end
