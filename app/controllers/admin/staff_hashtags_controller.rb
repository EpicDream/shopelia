class Admin::StaffHashtagsController < Admin::AdminController
  
  def index
  end
  
  def create
    hashtag = StaffHashtag.new(params[:staff_hashtag])
    if hashtag.valid?
      hashtag.save
      redirect_to admin_staff_hashtags_path
    else
      flash[:error] = hashtag.errors.full_messages
      render 'index'
    end
  end
  
  def destroy
    destroyed = StaffHashtag.find(params[:id]).destroy
    render json:{}, status: destroyed ? 200 : 500
  rescue
    render json:{}, status: 500
  end
end
