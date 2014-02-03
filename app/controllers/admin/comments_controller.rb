class Admin::CommentsController < Admin::AdminController
  
  def index
    @comments = Comment.last_ones(20)
  end
end
