class Api::Flink::CommentsController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!, :only => [:index]
  before_filter :prepare_scope
  before_filter :retrieve_comments , :only => [:index]
  before_filter :prepare_comment_hash, :only => [:create]

  api :GET, "/looks/:look_id/comments", "Get Comments of a look"
  def index
    render json: {
        comments: ActiveModel::ArraySerializer.new(@comments, scope:@scope)
    }
  end

  api :POST, "/looks/:look_id/comments", "Post Comment"
  def create
    @look = Look.find_by_uuid(params[:look_id].scan(/^[^\-]+/))
    @comment = @look.comments.create(@comment_hash)
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

  def prepare_comment_hash
    @comment_hash = params[:comment].merge({
                                               :developer_id => @developer.id,
                                               :flinker_id => current_flinker.id
                                           })
  end
end
