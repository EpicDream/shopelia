# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Shopelia::Application.initialize!

# Use Mandrillapp to deliver emails
ActionMailer::Base.smtp_settings = {
   :address   => 'smtp.mandrillapp.com',
   :port      => 587,
   :user_name => 'elarch@gmail.com',
   :password  => 'ad42d920-3de0-4b42-ab46-16c21bbe90c7'
}

