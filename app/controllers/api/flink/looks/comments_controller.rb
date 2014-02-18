class Api::Flink::Looks::CommentsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!, :only => [:index]
  before_filter :prepare_scope
  before_filter :retrieve_comments , :only => [:index]

  api :GET, "/looks/:look_id/comments", "Get Comments of a look"
  def index
    render json: {
        comments: ActiveModel::ArraySerializer.new(@comments, scope:@scope)
    }
  end

  api :POST, "/looks/:look_id/comments", "Post Comment"
  def create
    @comment = Comment.new(params[:comment].merge(comment_options))
    @comment.post_to_blog = @device.real_user?
    @comment.save
    
    if @comment.persisted?
      render json: CommentSerializer.new(@comment).as_json, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def retrieve_comments
    @comments = Look.find_by_uuid(params[:look_id].scan(/^[^\-]+/)).comments
  end

  def prepare_scope
    @scope = { developer:@developer, device:@device, flinker:current_flinker, short:true }
  end
  
  def comment_options
    look = Look.find_by_uuid(params[:look_id].scan(/^[^\-]+/))
    { flinker_id:current_flinker.id, look_id:look.id }
  end

end
