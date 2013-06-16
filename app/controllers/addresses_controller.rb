class AddressesController < ApplicationController

  def create
    @address = Address.new(params[:address])

    respond_to do |format|
      if @address.save
        format.html { redirect_to home_path, notice: I18n.t("addresses.success") }
        format.json { render json: @address, status: :created, location: @address }
      else
        format.html { render action: "new" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end
  
end
