class Api::Flink::BaseController < Api::ApiController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_flinker!

end
