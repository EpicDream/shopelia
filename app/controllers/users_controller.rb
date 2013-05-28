# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: current_user }
    end
  end

  def update
    if current_user.update_attributes(params[:user])
      flash[:notice] = "Vos modifications ont bien été enregistrées !"
      respond_to do |format|
        format.html {redirect_to root_url}
        format.json { head :no_content}
      end
    else
      respond_to do |format|
        format.html { render 'edit'}
        format.json { render json: current_user.errors, status: :unprocessable_entity}
      end
    end
  end

end
