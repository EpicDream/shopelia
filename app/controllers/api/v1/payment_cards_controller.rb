class Api::V1::PaymentCardsController < Api::V1::BaseController
  before_filter :retrieve_payment_card, :only => [:show, :destroy]

  def_param_group :payment_card do
    param :payment_card, Hash, :required => true, :action_aware => true do
      param :name, String, "Payment card name", :required => false
      param :number, String, "Payment card number", :required => true
      param :exp_month, String, "Expiration month (01..12)", :required => true
      param :exp_year, String, "Expiration year 4 digits (ex: 2013)", :required => true
      param :cvv, String, "Card cvv number (ex: 123)", :required => true
    end
  end

  api :GET, "/payment_cards/:id", "Show a payment card"
  def show
    render json: PaymentCardSerializer.new(@payment_card).as_json
  end
  
  api :GET, "/payment_cards", "Get all payment cards for current user"
  def index
    render json: ActiveModel::ArraySerializer.new(PaymentCard.find_all_by_user_id(current_user.id))
  end

  api :POST, "/payment_cards", "Create a payment card for current user"
  param_group :payment_card
  def create
    @payment_card = PaymentCard.new(params[:payment_card].merge({ user_id: current_user.id }))

    if @payment_card.save
      render json: PaymentCardSerializer.new(@payment_card).as_json, status: :created
    else
      render json: @payment_card.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, "/payment_cards/:id", "Destroy a payment card"
  def destroy
    @payment_card.destroy

    head :no_content
  end
  
  private
  
  def retrieve_payment_card
    @payment_card = PaymentCard.where(:id => params[:id], :user_id => current_user.id).first!
  end
  
end
