require 'flinker_merge'

class Admin::FlinkerMergesController < Admin::AdminController

  def new
  end
  
  def show
    @flinker = Flinker.where(email:params[:flinker_email]).first
    @target = Flinker.publishers.where(url:params[:target_url]).first
  end
  
  def create
    @flinker = Flinker.find(params[:flinker_id])
    @target = Flinker.find(params[:target_id])
    FlinkerMerge.new(@flinker, @target).merge
    flash[:notice] = "La fusion s'est correctement déroulée, ouf!"
  rescue
    flash[:error] = "Une erreur s'est produite lors du merge. Flinker ID : #{@flinker.id} Target ID : #{@target.id}"
    @target = nil
  ensure
    render 'merge_result'
  end
end
