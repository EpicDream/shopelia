class Api::V1::TracesController < Api::V1::BaseController
  skip_before_filter :authenticate_user!
  skip_before_filter :authenticate_developer!

  api :POST, "/api/traces", "Create trace"
  def create
    head :no_content
  end
end