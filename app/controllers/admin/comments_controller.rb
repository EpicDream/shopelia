class Admin::CommentsController < Admin::AdminController
  
  def index
    @comments = Comment.last_ones(50)
  end
  
  def reply
    comment = Comment.find(params[:comment_id])
    Comment.create(body:params[:comment][:body], look_id:comment.look.id, flinker_id:Flinker.flinkHQ.id)
    render json:{}, status:200
  rescue
    render json:{}, status:500
  end
end
