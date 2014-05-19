class Api::Flink::Mailjet::UnsubscribesController < Api::Flink::BaseController
  skip_before_filter :authenticate_flinker!
  skip_before_filter :retrieve_device
  skip_before_filter :authenticate_developer!
  
  def create
    File.open("/tmp/mailjet-call.log", "a+") { |f| f.write("\n[MAILJET]#{params}\n") }
    render json:{}, status:200
  end
end
