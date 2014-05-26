class Admin::NewslettersController < Admin::AdminController
  EMAILS_TEST = ["olivefisch@gmail.com", "anoiaque@me.com", "pauline.gandolfini@gmail.com"]
  
  def new
    @newsletter = Newsletter.last || Newsletter.create
  end
  
  def update
    newsletter = Newsletter.last
    newsletter.update_attributes(params[:newsletter])
    redirect_to new_admin_newsletter_path
  end
  
  def test
    EMAILS_TEST.each { |email| 
      flinker = Flinker.where(email:email).first
      Emailer.newsletter(flinker, true).deliver if flinker 
    }
    redirect_to new_admin_newsletter_path
  end
  
end