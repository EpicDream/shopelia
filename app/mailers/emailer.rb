# -*- encoding : utf-8 -*-
class Emailer < ActionMailer::Base
  helper :orders
  
  def contact name, email, message
    mail( :to => "Contact Shopelia <contact@shopelia.fr>",
          :subject => "Formulaire de contact SHOPELIA",
          :from => "#{name} <#{email}>",
          :body => message)
  end

  ##################################################################################
  
  def notify_order_creation order
    @order = order
    @vendor = @order.merchant.name
    @product = @order.order_items.first.product
    mail( :to => @order.user.email,
          :subject => "Votre commande chez #{@vendor} a bien été prise en compte !",
          :from => "Shopelia <contact@shopelia.fr>")
  end

  def notify_order_success order
    @order = order
    @vendor = @order.merchant.name
    @vendor_url = @order.merchant.url
    @product = @order.order_items.first.product
    @account = @order.merchant_account
    mail( :to => @order.user.email,
          :subject => "Votre commande a été acceptée par #{@vendor}",
          :from => "Shopelia <contact@shopelia.fr>")
  end

  def notify_order_failure order
    @order = order
    @vendor = @order.merchant.name
    @product = @order.order_items.first.product
    mail( :to => @order.user.email,
          :subject => "IMPORTANT ! Votre commande chez #{@vendor} n'a pas pu aboutir",
          :from => "Shopelia <contact@shopelia.fr>")
  end

  def notify_order_price_change order
    @order = order
    @vendor = @order.merchant.name
    @product = @order.order_items.first.product
    @old_price = @order.expected_price_total
    @new_price = @order.prepared_price_total
    mail( :to => @order.user.email,
          :subject => "ATTENTION ! Le prix de votre commande a evolué !",
          :from => "Shopelia <contact@shopelia.fr>")
  end

  ##################################################################################

  def leetchi_user_creation_failure user, errors
    @user = user
    @errors = errors
    mail( :to => "Eric <eric@shopelia.com>",
          :subject => "[SUPERVISOR][CRITICAL] Leetchi user creation failure",
          :from => "Supervisor <noreply@shopelia.com>")
  end
  
  def leetchi_card_creation_failure card, errors
    @card = card
    @errors = errors
    mail( :to => "Eric <eric@shopelia.com>",
          :subject => "[SUPERVISOR][CRITICAL] Leetchi card creation failure",
          :from => "Supervisor <noreply@shopelia.com>")
  end

  def notify_admin_user_creation user
    @user = user
    mail( :to => "Shopelia <contact@shopelia.fr>",
          :subject => "Nouvel utilisateur inscrit #{@user.name}",
          :from => "Admin Shopelia <contact@shopelia.fr>")
  end

  def notify_admin_order_creation order
    @order = order
    mail( :to => "Shopelia <contact@shopelia.fr>",
          :subject => "Nouvelle commande reçue de #{@order.user.name}",
          :from => "Admin Shopelia <contact@shopelia.fr>")
  end
   
end
