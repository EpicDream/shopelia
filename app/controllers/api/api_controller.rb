class Api::ApiController < ActionController::Base

  rescue_from ArgumentError do |e|
    render :json => {"ErrorType" => "Validation Error", "message" => e.message},
           :code => :bad_request
   end
           
end
