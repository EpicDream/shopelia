class Api::V1::TracesController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!
  before_filter :prepare_params

  api :POST, "/api/traces", "Create trace"
  def create
    TracesWorker.perform_async({
      :user_id => current_user.try(:id),
      :device_id => @device.id,
      :ressource => @ressource,
      :action => @action,
      :extra_id => @extra_id,
      :extra_text => @extra_text,
      :ip_address => request.remote_ip
    })
    head :no_content
  end

  private

  def prepare_params
    @ressource = params[:trace][:ressource]
    @action = params[:trace][:action]
    @extra_id = params[:trace][:extra_id]
    @extra_text = params[:trace][:extra_text]
  end
end