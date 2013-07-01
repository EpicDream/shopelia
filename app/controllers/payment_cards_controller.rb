class PaymentCardsController < ApplicationController
  before_filter :authenticate_user!
  
  def new
    @card = PaymentCard.new
    render partial:"form"
  end

  def create
    @card = PaymentCard.new(params[:payment_card].merge(user_id:current_user.id));

    respond_to do |format|
      if @card.save
        format.html { redirect_to home_path, notice: I18n.t("payment_cards.success") }
        format.json { render json: @card, status: :created, location: @card }
        format.js
      else
        logger.error @card.errors.inspect
        format.html { render partial:"form" }
        format.json { render json: @card.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
end
