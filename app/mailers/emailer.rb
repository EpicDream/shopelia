# -*- encoding : utf-8 -*-
class Emailer < ActionMailer::Base

  def contact(name, email, message)
    mail(
      :to => "Contact Shopelia <contact@shopelia.fr>",
      :subject => "Formulaire de contact SHOPELIA",
      :from => "#{name} <#{email}>",
      :body => message)
  end

end
