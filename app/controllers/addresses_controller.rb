class AddressesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :retrieve_address, :only => [:show, :destroy, :update]
  
  def new
    @address = Address.new(first_name:current_user.first_name, last_name:current_user.last_name)
  end
  
  def create
    @address = Address.new(params[:address].merge(user_id:current_user.id));

    respond_to do |format|
      if @address.save
        format.html { redirect_to home_path, notice: I18n.t("addresses.success") }
        format.json { render json: @address, status: :created, location: @address }
        format.js
      else
        format.html { render partial:"form" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @address.destroy
    
    respond_to do |format|
      format.html { redirect_to addresses_path }
      format.json { head :ok }
      format.js
    end
  end    
  
  private
  
  def retrieve_address
    @address = Address.find(params[:id])
    render :status => :unauthorized and return if @address.user.id != current_user.id
  end
  
end
