# -*- encoding : utf-8 -*-
class Emailer < ActionMailer::Base

  def contact name, email, message
    mail( :to => "Contact Shopelia <contact@shopelia.fr>",
          :subject => "Formulaire de contact SHOPELIA",
          :from => "#{name} <#{email}>",
          :body => message)
  end
  
  def notify_order_creation order
    @order = order
    mail( :to => @order.user.email,
          :subject => "Votre commande chez #{@order.merchant.vendor} a bien été prise en compte !",
          :from => "Shopelia <contact@shopelia.fr>")
  end
  
end
