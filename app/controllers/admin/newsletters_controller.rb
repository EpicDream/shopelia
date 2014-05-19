class Admin::NewslettersController < Admin::AdminController
  
  def new
    @newsletter = Newsletter.last || Newsletter.create
  end
  
  def update
    newsletter = Newsletter.last
    newsletter.update_attributes(params[:newsletter])
    redirect_to new_admin_newsletter_path
  end
  
end