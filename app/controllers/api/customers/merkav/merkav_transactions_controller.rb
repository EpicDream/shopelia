class Api::Customers::Merkav::MerkavTransactionsController < Api::Customers::Merkav::BaseController
  skip_before_filter :authenticate_user!
  before_filter :ensure_merkav_api_key!

  def index
    @transactions = MerkavTransaction.all
    render json: ActiveModel::ArraySerializer.new(@transactions).as_json
  end

  def create
    @transaction = MerkavTransaction.new(params[:merkav_transaction])
    if @transaction.save
      render json: MerkavTransactionSerializer.new(@transaction).as_json[:merkav_transaction], status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  def show
    @transaction = MerkavTransaction.find(params[:id])
    render json: MerkavTransactionSerializer.new(@transaction).as_json[:merkav_transaction]
  end
end