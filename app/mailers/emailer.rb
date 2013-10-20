# -*- encoding : utf-8 -*-
class Emailer < ActionMailer::Base
  helper :orders
  
  def contact name, email, message
    mail( :to => "Contact Shopelia <contact@shopelia.fr>",
          :subject => "Formulaire de contact SHOPELIA",
          :from => "#{name} <#{email}>",
          :body => message)
  end

  def send_user_download_link email
    @email = email
    mail( :to => @email,
          :subject => "Lien de téléchargement pour Shopelia",
          :from => "Shopelia <contact@shopelia.fr>")
  end

  ##################################################################################

  def send_products_feed_to_developer(developer, filename)
    attachments[filename.gsub("/tmp/", "")] = File.read(filename)
    mail( :to => developer.email,
          :subject => "Products feed for #{developer.name} [#{Time.now.strftime("%Y-%m-%d")}]", 
          :from => "Shopelia Developers <contact@shopelia.com>",
          :body => "Please find attached your daily products extract" )
  end

  ##################################################################################

  def send_cadeau_shaker_report(developer, log)
    mail( :to => developer.email,
          :subject => "Orders batch report for #{developer.name} [#{Time.now.strftime("%Y-%m-%d")}]", 
          :from => "Shopelia Developers <contact@shopelia.com>",
          :body => log.join("\n") )
  end

  ##################################################################################
  
  def notify_order_creation order
    @order = order
    @vendor = @order.merchant.name
    @product = @order.order_items.first.product
    mail( :to => @order.user.email,
          :subject => "Votre commande chez #{@vendor} est actuellement en cours de traitement !",
          :from => "Shopelia <contact@shopelia.fr>")
  end

  def notify_order_success order
    @order = order
    @vendor = @order.merchant.name
    @vendor_url = @order.merchant.url
    @product = @order.order_items.first.product
    @account = @order.merchant_account
    mail( :to => @order.user.email,
          :subject => "Votre commande a été passée avec succès chez #{@vendor}",
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
          :subject => "ATTENTION ! Le prix de votre commande a évolué !",
          :from => "Shopelia <contact@shopelia.fr>")
  end

  def notify_cart_item_creation item
    @item = item
    @product = @item.product_version.product
    @user = @item.cart.user
    mail( :to => @user.email,
          :subject => "Suivi de produit activé pour #{@product.name}",
          :from => "Shopelia <contact@shopelia.fr>")
  end

  ##################################################################################

  def admin_daily_report stats
    @stats = stats
    mail( :to => "Shopelia <staff@shopelia.com>",
          :subject => "Daily global statistics for #{@stats.date.to_s(:long)}",
          :from => "Admin Shopelia <admin@shopelia.fr>")
  end

  def notify_admin_user_creation user
    @user = user
    mail( :to => "Shopelia <admin@shopelia.fr>",
          :subject => "Nouvel utilisateur inscrit #{@user.name}",
          :from => "Admin Shopelia <admin@shopelia.fr>")
  end

  def notify_admin_cart_item_creation item
    @item = item
    mail( :to => "Shopelia <admin@shopelia.fr>",
          :subject => "Nouveau produit suivi #{@item.product_version.product.name}",
          :from => "Admin Shopelia <admin@shopelia.fr>")
  end

  def notify_admin_order_creation order
    @order = order
    @user_agent = ENV['HTTP_USER_AGENT']
    mail( :to => "Shopelia <admin@shopelia.fr>",
          :subject => "Nouvelle commande reçue de #{@order.user.name}",
          :from => "Admin Shopelia <admin@shopelia.fr>")
  end
   
  def notify_admin_order_failure order
    @order = order
    mail( :to => "Shopelia <admin@shopelia.fr>,anoiaque@gmail.com",
          :subject => "Echec de l'injection de la commande passée par #{@order.user.name}",
          :from => "Admin Shopelia <admin@shopelia.fr>")
  end
end