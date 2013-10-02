require 'nexmo'

class SendTextController <  ApplicationController

  def send_text_message
    phone_number = params[:phone_number]
    nexmo = Nexmo::Client.new('00dadf0d', '9d7715e2')
    response = nexmo.send_message({:to => phone_number , :from => 'Shopelia', :text => 'http://10.0.0.19/download'})
    if response.ok?
        # do something with response.object
        render :json => response.to_json
    else
        render :json => { :errors => response.to_json }
        # handle the error
    end
  end
end
