class Api::Customers::Merkav::StatsController < Api::Customers::Merkav::BaseController
  skip_before_filter :authenticate_user!
  before_filter :ensure_merkav_api_key!

  def index
    render json: {
      transactions_count: MerkavTransaction.count,
      successfull_transactions_count: MerkavTransaction.where(status:'success').count,
      successfull_transactions_total_amount: MerkavTransaction.where(status:'success').sum(:amount)
    }
  end
end