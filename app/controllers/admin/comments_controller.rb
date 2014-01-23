class Admin::CommentsController < Admin::AdminController
  
  def index
    @comments = Comment.paginate(:page => params[:page], :per_page => 20)
  end
end
