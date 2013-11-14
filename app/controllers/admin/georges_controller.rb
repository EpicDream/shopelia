class Admin::GeorgesController < Admin::AdminController

  def status
    GeorgesStatus.set(params[:status])
    head :no_content
  end
end