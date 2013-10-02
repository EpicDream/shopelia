require 'nexmo'

class SendTextController <  ApplicationController

  def send_text_message
    if !params[:phone_number].nil?
      phone_number = params[:phone_number]
      nexmo = Nexmo::Client.new('00dadf0d', '9d7715e2')
      response = nexmo.send_message({:to => phone_number , :from => 'Shopelia', :text => 'http://10.0.0.19:3000/download'})
      if response.ok?
          # do something with response.object
          render :json => response.to_json
      else
          render :json => { :errors => response.to_json }
          # handle the error
      end
    elsif !params[:email].nil?
        Emailer.send_user_download_link(params[:email]).deliver
        render :json => { :success => true }
    end
  end

end
