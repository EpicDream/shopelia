class ContactController < ApplicationController

  def create
    Emailer.contact(params['name'], params['email'], params['message']).deliver 
    render :json => ['success'].to_json
  end

end
