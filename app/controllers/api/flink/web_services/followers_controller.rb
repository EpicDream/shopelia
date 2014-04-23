class Api::Flink::WebServices::FollowersController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!, only: :count
  
  def count
    @flinker = Flinker.where(username:params[:username]).first

    if @flinker
      render json:{ followers: { count: @flinker.followers.count } }, status:200
    else
      render json:{}, status: 404
    end
  end
  
end