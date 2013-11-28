class Admin::Georges::TracesController < Admin::AdminController
  before_filter :retrieve_trace

  def show
    respond_to do |format|
      format.js
    end
  end

  private

  def retrieve_trace
    @trace = Trace.find(params[:id])
  end
end