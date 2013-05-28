# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
  end

  def update
    if current_user.update_attributes(params[:user])
      flash[:notice] = "Vos modifications ont bien été enregistrées !"
      redirect_to root_url
    else
      render 'edit'
    end
  end

end
