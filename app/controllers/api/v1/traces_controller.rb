class Api::V1::TracesController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!

  api :POST, "/api/traces", "Create trace"
  def create
    (params[:traces] || []).each do |trace|
      TracesWorker.perform_async({
        :user_id => current_user.try(:id),
        :device_id => @device.id,
        :resource => trace[:resource],
        :action => trace[:action],
        :extra_id => trace[:extra_id],
        :extra_text => trace[:extra_text],
        :ip_address => request.remote_ip
      })
    end
    head :no_content
  end
end