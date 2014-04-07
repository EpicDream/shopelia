class Admin::CommentsController < Admin::AdminController
  
  def index
    @comments = Comment.last_ones(50)
  end
end
