class Admin::PostsController < Admin::AdminController
  before_filter :retrieve_post, :only => [:show, :update]
  
  def index
    @posts = Post.where(status:"#{params[:status] || 'pending'}").order("published_at desc")
  end
  
  def show
    @products, @links = @post.convert
  end

  def update
    @post.update_attributes(status: params[:status], processed_at: Time.now)
    if params[:status] == 'published'
      @look.update_attributes(is_published: true)
      (params[:images] || []).each do |url|
        @look.look_images << LookImage.new(url:url)
      end
    end
    respond_to do |format|
      format.js
    end    
  end

  private

  def retrieve_post
    @post = Post.find(params[:id])
    @look = @post.generate_look
  end
end