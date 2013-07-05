class AddressesController < ApplicationController
  before_filter :authenticate_user!
  
  def new
    @address = Address.new(first_name:current_user.first_name, last_name:current_user.last_name)
    render partial:"form"
  end
  
  def show
    @address = Address.find(params[:id])
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
    @address = Address.find(params[:id])
    @address.destroy
    
    respond_to do |format|
      format.html { redirect_to addresses_path }
      format.json { head :ok }
      format.js
    end
  end    
  
end
